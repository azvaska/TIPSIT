<?php
session_start();
if (!isset($_SESSION["userId"])) {
    //    header("Location: ./login.php");
    //    die();
    ob_start();
    include $_SERVER['DOCUMENT_ROOT'] . "/php/pages/login.php";
    $file = ob_get_clean();
    echo $file;
    die();
}

if(!isset($_GET['q'])){
    header("Location: ./home");
}

function isSelected($page)
{
    if (isset($_GET['q'])) {
        if ($_GET['q'] == $page) {
            return "selected";
        }
    }
    return "";
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stats Panel</title>
    <link rel="stylesheet" href="/w/w/w/css/default.css">
    <link rel="stylesheet" href="/w/w/w/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/ol@v7.3.0/dist/ol.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ol@v7.3.0/ol.css">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

    <script src="/w/w/w/js/load_css.js"></script>
    <script type="module" src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.3.0/chart.umd.js"></script>

    <script src="https://cdn.jsdelivr.net/npm/elm-pep@1.0.6/dist/elm-pep.js"></script>
    <link rel="shortcut icon" href="https://avatars.githubusercontent.com/u/117534024?s=200&v=4" type="image/x-icon">

</head>

<body>

    <div id="left">
        <img class="header_logo" src="/w/w/w/img/logo.png" alt="">
        <div class="sidebar__wrap" >
            <div id="sidebar" style="padding: 1vw;">
                <a class="<?=isSelected("home")?>" href="home">Home</a>
                <a class="<?=isSelected("admin")?>" href="./admin">Admin</a>
                <a class="<?=isSelected("mapHeat")?>" href="/mapHeat">Heat Map</a>
                <a class="<?=isSelected("dataPerHourBarGraph")?>" href="/dataPerHourBarGraph">Data per Hour</a>
                <a class="<?=isSelected("avgTravel")?>" href="/avgTravel">Avg Travel Distance</a>
            </div>
        </div>
    </div>

    
    <div id="center">
        <a class="header_user" href="/settings">User: <b><?php echo $_SESSION["username"]; ?></b></a>
        <?php
        ob_start();
        include $_SERVER['DOCUMENT_ROOT'] . "/php/pages/" . $_GET['q'] . '.php';
        $file = ob_get_clean();
        echo $file;
        die();
        ?>
    </div>
</body>

</html>