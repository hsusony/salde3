<?php
/**
 * Database Configuration
 * SQL Server 2008 Connection Settings
 */

class Database {
    private static $instance = null;
    private $connection;
    
    // SQL Server Configuration
    private $serverName = "localhost\\MORABSQLE";
    private $database = "SalesManagementDB";
    private $username = "sa";
    private $password = "";
    
    private function __construct() {
        try {
            $connectionInfo = array(
                "Database" => $this->database,
                "UID" => $this->username,
                "PWD" => $this->password,
                "CharacterSet" => "UTF-8",
                "ReturnDatesAsStrings" => true
            );
            
            $this->connection = sqlsrv_connect($this->serverName, $connectionInfo);
            
            if ($this->connection === false) {
                throw new Exception("Database connection failed: " . print_r(sqlsrv_errors(), true));
            }
        } catch (Exception $e) {
            die(json_encode([
                'success' => false,
                'message' => 'Database connection error: ' . $e->getMessage()
            ]));
        }
    }
    
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    public function getConnection() {
        return $this->connection;
    }
    
    public function query($sql, $params = []) {
        $stmt = sqlsrv_query($this->connection, $sql, $params);
        
        if ($stmt === false) {
            throw new Exception("Query failed: " . print_r(sqlsrv_errors(), true));
        }
        
        return $stmt;
    }
    
    public function fetchAll($stmt) {
        $results = [];
        while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
            $results[] = $row;
        }
        return $results;
    }
    
    public function fetchOne($stmt) {
        return sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
    }
    
    public function execute($sql, $params = []) {
        $stmt = sqlsrv_query($this->connection, $sql, $params);
        
        if ($stmt === false) {
            throw new Exception("Execute failed: " . print_r(sqlsrv_errors(), true));
        }
        
        return $stmt;
    }
    
    public function lastInsertId() {
        $stmt = $this->query("SELECT @@IDENTITY AS LastID");
        $row = $this->fetchOne($stmt);
        return $row['LastID'];
    }
    
    public function beginTransaction() {
        sqlsrv_begin_transaction($this->connection);
    }
    
    public function commit() {
        sqlsrv_commit($this->connection);
    }
    
    public function rollback() {
        sqlsrv_rollback($this->connection);
    }
    
    public function __destruct() {
        if ($this->connection) {
            sqlsrv_close($this->connection);
        }
    }
}
