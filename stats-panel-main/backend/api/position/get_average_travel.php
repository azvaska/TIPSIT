<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/position.php');

if (isset($_SESSION['userId'])) {
    if (isset($_GET['start']) && isset($_GET['end']))
        echo json_encode(Position::average_travel($_GET['start'], $_GET['end']));
    else
        echo json_encode(Position::average_travel(1679225545000, 1679305530000));
}
?>