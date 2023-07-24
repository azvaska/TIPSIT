<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/bubbly.php');
if (isset($_SESSION['userId'])) {
    if ($_SESSION['isAdmin'] == "1") {
        if (isset($_GET['id'])) {
            echo Bubbly::unbanUser($_GET['id']);
        } else {
            echo "Error: Malformed request.";
        }
    }
}else{
    echo "Error: Forbidden.";
}


?>