<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    protected $table = 'Units';
    protected $primaryKey = 'UnitID';
    public $timestamps = false;

    protected $fillable = [
        'UnitName',
    ];

    public function products()
    {
        return $this->hasMany(Product::class, 'UnitID', 'UnitID');
    }
}
