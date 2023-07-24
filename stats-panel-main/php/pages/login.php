<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <!-- <meta name="viewport" content="width=device-width, initial-scale=1.0"> -->
    <title>Login Bubbly</title>
    <link rel="stylesheet" href="/w/w/w/css/login.css">
    <script>
        const login = (e) => {
            e.preventDefault();
            let formElement = document.getElementById("login");
            const data = new URLSearchParams();
            for (const pair of new FormData(formElement)) {
                data.append(pair[0], pair[1]);
            }

            fetch("/backend/api/login.php", {
                    method: 'post',
                    body: data,
                })
                .then((res) => {
                    if (res.ok) {
                        let error_element = document.getElementById("error_message");
                        error_element.textContent = "";
                        return res.text();
                    } else {
                        throw ("Wrong Credentials");
                    }
                }).then((data) => {
                    console.log(data);

                    window.location.href = "/home";
                }).catch((e) => {
                    let error_element = document.getElementById("error_message");
                    error_element.textContent = e;
                    console.log(e);

                });
        }
        window.login = login
    </script>
</head>

<body>
    <div id="blob"></div>
    <div id="blur"></div>

    <div class="card">
        <form id="login" onsubmit="return window.login(event)">
            <h1 data-value="Bubbly Login">Bubbly Login</h1>
            <hr>
            <div id="user" class="textfield">
                <input type="text" name="user" required placeholder="Email">
            </div>
            <div id="password" class="textfield">
                <input type="password" name="passwd" required placeholder="Password">
            </div>
            <p id="error_message"></p>
            <button type="submit" id="loginbutton">Login</button>

        </form>
    </div>

    <script>
        const letters = "abcdefghijklmnopqrstuvwxyz";

        let interval = null;

        const h1text = document.querySelector("h1");

        setInterval(() => {
                let iteration = 0;

                clearInterval(interval);

                interval = setInterval(() => {
                    h1text.textContent = h1text.textContent
                        .split("")
                        .map((letter, index) => {
                            if (index < iteration || letter == ' ') {
                                return h1text.dataset.value[index];
                            }
                            if (letter === letter.toUpperCase())
                                return letters[Math.floor(Math.random() * 26)].toUpperCase();
                            else
                                return letters[Math.floor(Math.random() * 26)];
                        })
                        .join("");

                    if (iteration >= h1text.dataset.value.length) {
                        clearInterval(interval);
                    }

                    ++iteration;
                }, 50);
            },
            30000
        );

        if (navigator.userAgent.includes('Opera') || navigator.userAgent.includes('OPR')) {
            console.log('Opera');
        } else if (navigator.userAgent.includes('Edg')) {
            console.log('Edge');
        } else if (navigator.userAgent.includes('Chrome')) {
            console.log('Chrome');
        } else if (navigator.userAgent.includes('Safari')) {
            console.log('Safari');
        } else if (navigator.userAgent.includes('Firefox')) {
            console.log('Firefox');
        } else if (navigator.userAgent.includes('MSIE') || (!!document.documentMode)) {
            console.log('IE');
        } else {
            console.log('unknown');
        }
        const blob = document.getElementById("blob");

        let width = window.innerWidth;
        let height = window.innerHeight;
        let x = 0;
        let y = 0;

        let xsize = blob.clientWidth;
        let ysize = blob.clientHeight;
        let xVelocity = 8;
        let yVelocity = 8;
        let speed = 5;

        let mouseCoords = {
            x: 0,
            y: 0
        };

        function updateMouseCoords(event) {
            mouseCoords.x = event.clientX;
            mouseCoords.y = event.clientY;
        }

        function move() {
            blob.style.left = x + 'px';
            blob.style.top = y + 'px';
        }

        function followMouse() {
            move(x, y);
            let diff = mouseCoords.x - x;
            if (diff != 0) {
                x += diff > 0 ? xVelocity : -xVelocity;
                xVelocity = Math.abs(diff) * 50 / width;
                x = Math.max(-1, Math.min(width + xsize - 1, x));
            }

            diff = mouseCoords.y - y;
            if (diff != 0) {
                y += diff > 0 ? yVelocity : -yVelocity;
                yVelocity = Math.abs(diff) * 50 / height;
                y = Math.max(-1, Math.min(height + ysize - 1, y));
            }
        }
        window.addEventListener('mousemove', updateMouseCoords);
        setInterval(followMouse, speed);
    </script>
</body>

</html>