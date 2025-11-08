<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Installment extends Model
{
    use HasFactory;

    protected $table = 'Installments';
    protected $primaryKey = 'InstallmentID';
    public $timestamps = false;

    protected $fillable = [
        'SaleID',
        'CustomerID',
        'Amount',
        'DueDate',
        'PaidDate',
        'Status',
        'Notes',
    ];

    protected $casts = [
        'Amount' => 'decimal:2',
        'DueDate' => 'date',
        'PaidDate' => 'date',
    ];

    public function sale()
    {
        return $this->belongsTo(Sale::class, 'SaleID', 'SaleID');
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'CustomerID', 'CustomerID');
    }
}