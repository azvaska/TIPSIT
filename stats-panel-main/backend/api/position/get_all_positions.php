<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/position.php');
// $conn =  DB::connect_relational();
// $password_hash = password_hash("a", PASSWORD_BCRYPT);
// $query = $conn->query("INSERT INTO users(username, password,email) VALUES ('a', '$password_hash','ad@a.c')");
// $conn->close();


// echo Position::get_all_positions_smooth(1679221545000, 1679305530000);

//DB::connect_db();
if (isset($_SESSION['userId'])) {
    if (isset($_GET['start']) && isset($_GET['end']))
        echo Position::get_all_positions_smooth($_GET['start'], $_GET['end']);
    else
        echo Position::get_all_positions_smooth(1679225545000, 1679305530000);
    // echo Position::get_all_positions_smooth(0, 1679758234450);
}
?>