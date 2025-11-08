<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $table = 'Categories';
    protected $primaryKey = 'CategoryID';
    public $timestamps = false;

    protected $fillable = [
        'CategoryName',
        'Description',
    ];

    public function products()
    {
        return $this->hasMany(Product::class, 'CategoryID', 'CategoryID');
    }
}
