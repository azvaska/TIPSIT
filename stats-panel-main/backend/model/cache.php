<?php
require_once('db.php');
class Cache
{
    public $conn = null;
    function __construct()
    {
        $conn = DB::connect_cache();
    }
    function set_redis($key, $value)
    {
        $this->conn->HSET($key, $value);
    }
    function get_redis($key)
    {
        $result = $this->conn->HGET($key);
        }
    
}