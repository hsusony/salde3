<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Customer extends Model
{
    use HasFactory;

    protected $table = 'Customers';
    protected $primaryKey = 'CustomerID';
    public $timestamps = false;

    protected $fillable = [
        'CustomerName',
        'Phone',
        'Address',
        'Email',
        'TaxNumber',
        'Notes',
        'Balance',
        'IsActive',
    ];

    protected $casts = [
        'Balance' => 'decimal:2',
        'IsActive' => 'boolean',
    ];

    public function sales()
    {
        return $this->hasMany(Sale::class, 'CustomerID', 'CustomerID');
    }

    public function installments()
    {
        return $this->hasMany(Installment::class, 'CustomerID', 'CustomerID');
    }
}
