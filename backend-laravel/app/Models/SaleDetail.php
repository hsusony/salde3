<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SaleDetail extends Model
{
    use HasFactory;

    protected $table = 'SaleDetails';
    protected $primaryKey = 'DetailID';
    public $timestamps = false;

    protected $fillable = [
        'SaleID',
        'ProductID',
        'Quantity',
        'UnitPrice',
        'TotalPrice',
    ];

    protected $casts = [
        'Quantity' => 'decimal:2',
        'UnitPrice' => 'decimal:2',
        'TotalPrice' => 'decimal:2',
    ];

    public function sale()
    {
        return $this->belongsTo(Sale::class, 'SaleID', 'SaleID');
    }

    public function product()
    {
        return $this->belongsTo(Product::class, 'ProductID', 'ProductID');
    }
}
