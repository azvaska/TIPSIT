<?php
// User::change_password("a", $old_password, $new_password);
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/user.php');
//DB::connect_db();
if (isset($_SESSION['userId'])) {
    if (isset($_POST['old_password']) && isset($_POST['new_password'])) {
        $old_password = $_POST['old_password'];
        $new_password = $_POST['new_password'];
        $username = $_SESSION['username'];
        if (User::change_password($username, $old_password, $new_password)) {
            echo "Password changed successfully";
        } else {
            http_response_code(400);
            echo "Error: Password not changed";
        }
    } else {
        http_response_code(400);

        echo "Error: Password not changed";
    }
    // echo Position::get_all_positions_smooth(0, 1679758234450);
}
else {
    http_response_code(400);

    echo "Error: Password not changed";
}
?>