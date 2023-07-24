<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/position.php');
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/bubbly.php');

// $conn =  DB::connect_relational();
// $password_hash = password_hash("a", PASSWORD_BCRYPT);
// $query = $conn->query("INSERT INTO users(username, password,email) VALUES ('a', '$password_hash','ad@a.c')");
// $conn->close();
if (isset($_SESSION['userId'])) {
    if (isset($_GET['start']) && isset($_GET['end']) && isset($_GET['user_id'])) {
        if ($_GET['user_id'] == ''){
            echo Position::get_all_positions_smooth($_GET['start'], $_GET['end']);

        }else{
            $userId = Bubbly::search_user_username($_GET['user_id'], 0, 1)[0];
            echo Position::get_position_smooth_user($_GET['start'], $_GET['end'], $userId['id']);
        }
    } else {
        echo Position::get_all_positions_smooth(1679221545000,1679305530000);
    } // echo Position::get_all_positions_smooth(0, 1679758234450);
}

//DB::connect_db();
// if (isset($_SESSION['userId']) ) {
//     echo Position::get_all_positions_smooth(1679221545000,1679305530000);
// }
