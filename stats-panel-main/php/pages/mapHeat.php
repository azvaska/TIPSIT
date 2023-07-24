<script>
    loadCss("/w/w/w/css/heatmap.css");
</script>
<script type="module" src="/w/w/w/js/mapHeat.js"></script>

<?php
if (isset($_SESSION["isAdmin"]) && $_SESSION["isAdmin"] == "1") {
    //    echo '<input type="text" id="userid" placeholder="user id">';
    //    echo '<button id="find">find</button>';
?>

    <div class="heatmap-toolbar">
        <div class="search-bar__wrap">
            <div class="search-bar">
                <input type="text" placeholder="User id &#128269;" onkeyup="typeUserId(this)" id="userid" />
            </div>
            <button id="find">Find</button>

            <input type="checkbox" name="Find User" id="find_user">
        </div>
    </div>

<?php
}
?>


<div id="top">
    <div id="text">
        <p>Amount of data: <b id="amount"></b></p>
    </div>
    <div id="map"></div>
</div>



<div id="bottom">
    <div id="section">
        <div class="line">
            <label for="radius">Radius</label>
            <input id="radius" class="slider" type="range" min="1" max="50" step="1" value="5" />
        </div>
        <div class="line">
            <label for="blur">Blur</label>
            <input id="blur" class="slider" type="range" min="1" max="50" step="1" value="9" />
        </div>

        <div class="line">
            <label for="date">Time Range</label>
            <input id="datepickerHeatMap" class="date-picker" data-time_24hr=true style="display: block;" />
        </div>
    </div>
</div>

<script>
    function typeUserId(input) {
        let findButton = document.getElementById("find");
        if (input.value !== '' && !findButton.classList.contains("enabled")) {
            findButton.classList.add("enabled");
        } else if (input.value === '' && findButton.classList.contains("enabled")) {
            findButton.classList.remove("enabled");
        }
    }
</script>