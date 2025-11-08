<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sale extends Model
{
    use HasFactory;

    protected $table = 'Sales';
    protected $primaryKey = 'SaleID';
    public $timestamps = false;

    protected $fillable = [
        'InvoiceNumber',
        'CustomerID',
        'SaleDate',
        'TotalAmount',
        'Discount',
        'Tax',
        'FinalAmount',
        'PaymentMethod',
        'Status',
        'Notes',
    ];

    protected $casts = [
        'SaleDate' => 'datetime',
        'TotalAmount' => 'decimal:2',
        'Discount' => 'decimal:2',
        'Tax' => 'decimal:2',
        'FinalAmount' => 'decimal:2',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'CustomerID', 'CustomerID');
    }

    public function details()
    {
        return $this->hasMany(SaleDetail::class, 'SaleID', 'SaleID');
    }

    public function installments()
    {
        return $this->hasMany(Installment::class, 'SaleID', 'SaleID');
    }
}
