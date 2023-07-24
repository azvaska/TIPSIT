<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/bubbly.php');
if (isset($_SESSION['userId'])) {
    if ($_SESSION['isAdmin'] == "1") {
        if (isset($_GET['query']) ) {
            if (isset($_GET['start']) && isset($_GET['limit'])){
                echo json_encode(Bubbly::search_user_username($_GET['query'],$_GET['start'],$_GET['limit']));

            }else{
                echo json_encode(Bubbly::search_user_username($_GET['query'],0,15));

            }
        } else {
            echo "Error: Malformed request.";
        }
    }
}else{
    echo "Error: Forbidden.";
}


?>