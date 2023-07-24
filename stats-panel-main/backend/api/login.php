<?php

session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/user.php');
// $conn =  DB::connect_relational();
// $password_hash = password_hash("toor", PASSWORD_BCRYPT);
// $query = $conn->query("INSERT INTO users(username, password,email) VALUES ('root', '$password_hash','root@to.or')");
// $conn->close();
// DB::connect_db();
if (isset($_POST['user']) && isset($_POST['passwd'])) {
    $res = User::login_user($_POST['user'], $_POST['passwd']);
    if ($res) {
        echo "Ok";
        die();
    }
    http_response_code(400);
    echo "Wrong Credentials";
}
/*
if (isset($_POST['register'])) {
    $username = $_POST['username'];
    $email = $_POST['email'];
    $password = $_POST['password'];
    $password_hash = password_hash($password, PASSWORD_BCRYPT);
    $query = $connection->prepare("SELECT * FROM users WHERE email=:email");
    $query->bindParam("email", $email, PDO::PARAM_STR);
    $query->execute();
    if ($query->rowCount() > 0) {
        echo '<p class="error">The email address is already registered!</p>';
    }
    if ($query->rowCount() == 0) {
        $query = $connection->prepare("INSERT INTO users(username, password, email) VALUES (:username, :password_hash, :email)");
        $query->bindParam("username", $username, PDO::PARAM_STR);
        $query->bindParam("password_hash", $password_hash, PDO::PARAM_STR);
        $query->bindParam("email", $email, PDO::PARAM_STR);
        $result = $query->execute();
        if ($result) {
            echo '<p class="success">Your registration was successful!</p>';
        } else {
            echo '<p class="error">Something went wrong!</p>';
        }
    }
}
?>
*/