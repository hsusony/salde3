<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $table = 'Products';
    protected $primaryKey = 'ProductID';
    public $timestamps = false;

    protected $fillable = [
        'ProductName',
        'Barcode',
        'CategoryID',
        'UnitID',
        'PurchasePrice',
        'SalePrice',
        'Stock',
        'MinimumStock',
        'ExpiryDate',
        'Notes',
        'IsActive',
    ];

    protected $casts = [
        'PurchasePrice' => 'decimal:2',
        'SalePrice' => 'decimal:2',
        'Stock' => 'decimal:2',
        'MinimumStock' => 'decimal:2',
        'ExpiryDate' => 'date',
        'IsActive' => 'boolean',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class, 'CategoryID', 'CategoryID');
    }

    public function unit()
    {
        return $this->belongsTo(Unit::class, 'UnitID', 'UnitID');
    }

    public function saleDetails()
    {
        return $this->hasMany(SaleDetail::class, 'ProductID', 'ProductID');
    }
}
