<div id="center">

    <h1 id="hi-text">Welcome back, <?php echo $_SESSION["username"]; ?>!</h1>

    <script src="/w/w/w/js/main.js" defer></script>
    <div class="homeRow" id="firstRow">
        <div class="element">
            <h4>CPU Usage</h4>
            <div class="graph">
                <canvas id="cpu"></canvas>
            </div>
        </div>
        <div class="element">
            <h4>Users positions</h4>
            <div class="graph">
                <canvas id="utenti"></canvas>
            </div>
        </div>
    </div>

    <div id="secondRow">
        <h4>Memory Usage</h4>
        <div class="element homeRow">
            <div class="graph">
                <canvas id="memory"></canvas>
            </div>
            <div class="graph">
                <canvas id="ram"></canvas>
            </div>
        </div>

    </div>
</div>