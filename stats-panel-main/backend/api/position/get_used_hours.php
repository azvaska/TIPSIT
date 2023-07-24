<?php
session_start();
date_default_timezone_set('UTC');
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/position.php');

if (!isset($_SESSION['userId'])) {
    echo "You are not logged in!";
    return;
}

$pos = null;
if (isset($_GET['start']) && isset($_GET['end']))
    $pos = Position::get_all_positions_smooth($_GET['start'], $_GET['end']);
else
    $pos = Position::get_all_positions_smooth(1679225545000, 1679305530000);

if ($pos == null) {
    echo "No positions found!";
    return;
}

$hours = array_fill(0, 24, 0);

$data = json_decode($pos, true);

// convert timestamp to hours
$date = new DateTime();
for ($i = 0; $i < count($data); $i++) {
    $date->setTimestamp($data[$i][2]);
    $hours[(int) $date->format('H')]++;
}

// convert to json
echo json_encode($hours);

?>