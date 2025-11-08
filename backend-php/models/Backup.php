<?php
/**
 * Backup Model
 * Handle database backup and restore
 */

require_once __DIR__ . '/../config/Database.php';

class Backup {
    
    private $db;
    private $backupDir = __DIR__ . '/../backups/';
    
    public function __construct() {
        $this->db = Database::getInstance();
        
        if (!file_exists($this->backupDir)) {
            mkdir($this->backupDir, 0777, true);
        }
    }
    
    // Create full database backup
    public function createBackup() {
        $filename = 'backup_' . date('Y-m-d_His') . '.sql';
        $filepath = $this->backupDir . $filename;
        
        $tables = $this->getAllTables();
        $backup = "-- Database Backup\n";
        $backup .= "-- Created: " . date('Y-m-d H:i:s') . "\n\n";
        
        foreach ($tables as $table) {
            $backup .= $this->backupTable($table);
        }
        
        file_put_contents($filepath, $backup);
        
        return [
            'filename' => $filename,
            'filepath' => $filepath,
            'size' => filesize($filepath),
            'tables' => count($tables),
            'created_at' => date('Y-m-d H:i:s')
        ];
    }
    
    // Get all table names
    private function getAllTables() {
        $sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
                WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = 'SalesManagementDB'";
        $stmt = $this->db->query($sql);
        $tables = $this->db->fetchAll($stmt);
        
        return array_column($tables, 'TABLE_NAME');
    }
    
    // Backup single table
    private function backupTable($table) {
        $backup = "\n-- Table: $table\n";
        
        // Get table structure
        $sql = "SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE 
                FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = ?";
        $stmt = $this->db->query($sql, [$table]);
        $columns = $this->db->fetchAll($stmt);
        
        // Get table data
        $dataSql = "SELECT * FROM $table";
        $dataStmt = $this->db->query($dataSql);
        $rows = $this->db->fetchAll($dataStmt);
        
        if (empty($rows)) {
            $backup .= "-- No data\n";
            return $backup;
        }
        
        $backup .= "-- Data ($table)\n";
        foreach ($rows as $row) {
            $values = [];
            foreach ($row as $key => $value) {
                if ($value === null) {
                    $values[] = 'NULL';
                } else {
                    $values[] = "'" . addslashes($value) . "'";
                }
            }
            
            $columnNames = implode(', ', array_keys($row));
            $backup .= "INSERT INTO $table ($columnNames) VALUES (" . implode(', ', $values) . ");\n";
        }
        
        return $backup;
    }
    
    // List all backups
    public function listBackups() {
        $backups = [];
        $files = glob($this->backupDir . 'backup_*.sql');
        
        foreach ($files as $file) {
            $backups[] = [
                'filename' => basename($file),
                'filepath' => $file,
                'size' => filesize($file),
                'created_at' => date('Y-m-d H:i:s', filemtime($file))
            ];
        }
        
        // Sort by creation date descending
        usort($backups, function($a, $b) {
            return strcmp($b['created_at'], $a['created_at']);
        });
        
        return $backups;
    }
    
    // Delete backup
    public function deleteBackup($filename) {
        $filepath = $this->backupDir . $filename;
        
        if (!file_exists($filepath)) {
            return false;
        }
        
        unlink($filepath);
        return true;
    }
    
    // Export data as JSON
    public function exportJSON($tables = []) {
        if (empty($tables)) {
            $tables = $this->getAllTables();
        }
        
        $data = [];
        
        foreach ($tables as $table) {
            $sql = "SELECT * FROM $table";
            $stmt = $this->db->query($sql);
            $data[$table] = $this->db->fetchAll($stmt);
        }
        
        $filename = 'export_' . date('Y-m-d_His') . '.json';
        $filepath = $this->backupDir . $filename;
        
        file_put_contents($filepath, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
        
        return [
            'filename' => $filename,
            'filepath' => $filepath,
            'size' => filesize($filepath),
            'tables' => count($tables),
            'created_at' => date('Y-m-d H:i:s')
        ];
    }
}
