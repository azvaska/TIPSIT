<?php
require_once("db.php");

class User
{
    public $username;
    public $password;
    public $isAdmin;
    public function __construct($username, $password, $isAdmin)
    {
        $this->username = $username;
        $password_hash = password_hash($password, PASSWORD_BCRYPT);

        $this->password = $password_hash;
        $this->isAdmin = $isAdmin;
    }

    public function create_user()
    {
        $conn =  DB::connect_relational();
        // echo "INSERT INTO users (username, password, isadmin) VALUES ($this->username, $this->password, false)";
        $result = $conn->query("INSERT INTO users (username, password, isadmin) VALUES ('$this->username', '$this->password', false)");
        if ($result === TRUE) {
            echo "New record created successfully";
        } else {
            echo "Error: <br>" . $conn->error;
        }
        $conn->close();
    }
    public static function login_user($username, $password)
    {
        $conn =  DB::connect_relational();
        $result = $conn->query("SELECT * FROM users WHERE username='$username'");
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            if (password_verify($password, $row["password"])) {
                $_SESSION["username"] = $row["username"];
                $_SESSION["isAdmin"] = $row["isadmin"];
                $_SESSION["userId"] = $row["id"];
                $conn->close();
                return true;
            }
            return false;
        }
        $conn->close();
        return false;
    }
    public static function change_password($username, $password,$new_password)
    {
        $conn =  DB::connect_relational();
        $password_hash = password_hash($new_password, PASSWORD_BCRYPT);
        $result = $conn->query("SELECT password FROM users WHERE username='$username'");
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            if (password_verify($password, $row["password"])) {
                echo "Password verified";
                $result = $conn->query("UPDATE users SET password='$password_hash' WHERE username='$username'");
                $conn->close();
                return true;
            }
            return false;
        }
      
    }

    public static function register_user($username, $email, $password)
    {
        $conn =  DB::connect_relational();
        $password_hash = password_hash($password, PASSWORD_BCRYPT);
        $result = $conn->query("SELECT * FROM users WHERE password='$password_hash'");

        if ($result->num_rows > 0) {
            echo "Questa password è già in uso da: " . $result->fetch_assoc()[0]->username;
            return false;
        } else {
            $result = $conn->query("INSERT INTO users(username, email, password) VALUE ('$username','$email','$password_hash')");
        }

        $conn->close();
        return false;
    }
}
