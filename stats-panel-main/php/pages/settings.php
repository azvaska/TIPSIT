<script defer>
    const reset_password = (e) => {
        e.preventDefault();
        let formElement = document.getElementById("login");
        //check that old password is correct and new password is equal to confirm password
        //if so, send to backend
        //if not, display error message

        const data = new URLSearchParams();
        for (const pair of new FormData(formElement)) {
            data.append(pair[0], pair[1]);
        }
        console.log(data);

        fetch("/backend/api/change_password.php", {
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

                // window.location.href = "/home";
            }).catch((e) => {
                let error_element = document.getElementById("error_message");
                error_element.textContent = e;
                console.log(e);

            });
    }
    window.reset_password = reset_password;

    window.signout = () => {
        // clear cookies
        document.cookie = "PHPSESSID=;path=/;domain=129.152.0.45;expires=Thu, 01 Jan 1970 00:00:01 GMT";
        // return to login
        window.location.href = "/login";
    };
</script>

<div>
    <form id="login" onsubmit="return window.reset_password(event)">
        <h1 data-value="Bubbly Login">Reset Password</h1>
        <hr>
        <div id="old_password" class=" search-bar">
            <input type="password" name="old_password" placeholder="Old Password" required>
        </div>
        <div id="new_password" class=" search-bar">
            <input type="password" name="new_password" placeholder="New Password" required>
        </div>
        <div id="new_password_repeat" class=" search-bar">
            <input type="password" name="new_password_repeat" placeholder="Repeat Password" required>
        </div>
        <p id="error_message"></p>
        <div>
            <button type="submit" id="loginbutton" class="b-button">Change password</button>
            <button id="signout" onclick="signout()" class="b-button">Sign Out</button>
        </div>
    </form>
</div>