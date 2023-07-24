<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/bubbly.php');
if (isset($_SESSION['userId'])) {
    if ($_SESSION['isAdmin'] == "1") {
        if (isset($_GET['start']) && isset($_GET['limit'])) {
            echo json_encode(Bubbly::getListUsers($_GET['start'],$_GET['limit']));
        }else{
            echo json_encode(Bubbly::getListUsers(0,10));

        }
    }else{
        echo "Error: Forbidden.";
    }
}


?>