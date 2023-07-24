<?php
session_start();
require_once($_SERVER['DOCUMENT_ROOT'] . '/backend/model/position.php');

if (isset($_GET['limit']))
    echo Position::get_max_user_positions($_GET['limit']);
else
    echo Position::get_max_user_positions();
