<?php

// use Exception;
use MongoDB\Client;
// use MongoDB\Driver\ServerApi;

class DB
{
    public static function connect_relational()
    {
        $server = "127.0.0.1";
        $user = "root";
        $password = "idroscimmia";
        $db = "bubbly_stats";

        $conn = mysqli_connect($server, $user, $password, $db);

        // Check connection
        if (mysqli_connect_errno()) {
            header("Location:error.php");
            echo "Failed to connect to MySQL: " . mysqli_connect_error();
        }
        return $conn;
    }

    public static function connect_relational2()
    {
        $server = "127.0.0.1";
        $user = "postgres";
        $password = "12345";
        $db = "bubbly";
        $port = 5432;

        $conn_string = "host=$server port=$port dbname=$db user=$user password=$password";
        $conn = pg_connect($conn_string);

        if (!$conn) {
            throw new Exception("Database Connection Error");
        }

        return $conn;
    }

    public static function connect_db()
    {
        ini_set('memory_limit', '-1');
        $uri = 'mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.8.0';
        // $uri = 'mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.8.0';
        $conn = new MongoDB\Driver\Manager($uri);
        // echo new DateTime('2023-03-21');
        return $conn;
    }
    public static function connect_cache(){
        $redis = new Redis(); 
        $redis->connect('127.0.0.1', 6379); 
        return $redis;
    }
}
