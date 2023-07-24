{
    const loadUser = (offset, limit) => {
        const url = `/backend/api/bubbly/get_list_users.php?start=${offset}&limit=${limit}`;
        let userlist = document.getElementById("user-list");
        userlist.innerHTML = "";
        fetch(url)
            .then(res => res.json())
            .then(async (d) => {
                //add to userlist (ul) the users from the database in the form of li with user-info
                d.forEach(user => {
                    let li = document.createElement("li");
                    //using this html commet as a template create a js that creates the li with the user info
                    li.innerHTML = `
                    <div class="user-row">
                        <img class="user-pic" src="w/w/w/img/user1.png" alt="User 1 Profile Picture">
                        <div class="user-info">
                            <div class="user-name">${user.name} ${user.surname}</div>
                            <div class="user-username">@${user.username}</div>
                        </div>
                        <button id="plus-button" onclick="window.openModal('${user.id}')">+</button>
                    </div>
                    `;
                    userlist.appendChild(li);

                });
            })
    }

    const loadUserBySearch = (filter, offset, limit) => {
        const url = `/backend/api/bubbly/search_user.php?query=${filter}&start=${offset}&limit=${limit}`;
        let userlist = document.getElementById("user-list");
        userlist.innerHTML = "";
        fetch(url)
            .then(res => res.json())
            .then(async (d) => {
                //add to userlist (ul) the users from the database in the form of li with user-info
                d.forEach(user => {
                    let li = document.createElement("li");
                    //using this html commet as a template create a js that creates the li with the user info
                    li.innerHTML = `
                    <div class="user-row">
                        <img class="user-pic" src="w/w/w/img/user1.png" alt="User 1 Profile Picture">
                        <div class="user-info">
                            <div class="user-name">${user.name} ${user.surname}</div>
                            <div class="user-username">@${user.username}</div>
                        </div>
                        <button id="plus-button" onclick="window.openModal('${user.id}')">+</button>
                    </div>
                    `;
                    userlist.appendChild(li);
                });
            })
    }

    const openModal = (id) => {
        let modal = document.getElementById("modal");
        modal.style.display = "block";
        const url = "/backend/api/bubbly/get_user.php?id=" + id;
        fetch(url)
            .then(res => res.json())
            .then(async (user) => {
                //add to userlist (ul) the users from the database in the form of li with user-info
                modal.innerHTML = `
                            <div class="modal-container">
                            <div class="modal-image__wrap">
                                <img class="modal-image" src="/w/w/w/img/user1.png" alt="">
                            </div>
                            <div class="modal-content">
                            <div class="main-info">
                                <div class="main-info__row">
                                    <p><a>Nome: </a><a class="userinfo">${user.name}</a></p>
                                    <p><a>Cognome: </a><a class="userinfo">${user.surname}</a></p>
                                </div>
                                <div class="main-info__row">
                                    <p><a>Sesso: </a><a class="userinfo">${user.gender}</a></p>
                                    <p><a>DDN: </a><a class="userinfo">${user.birth_date}</a></p>
                                </div>
                            </div>
                                <p><a>Username:</a><a class="userinfo">${user.username}</a></p>
                                <p><a>Email:   </a><a class="userinfo">${user.email}</a> </p>
                                <p><a>Telefono:</a><a class="userinfo">${user.phone}</a></p>
                                <p><a>Emoji:   </a><a class="userinfo">${user.emoji}</a></p>
                                <p><a>Bio:     </a><a class="userinfo">${user.bio}</a></p>
                                <p><a>Banned:</a><a class="userinfo">${user.is_active === 't' ? "No" : "Yes"}</a></p>

                                <button onClick="window.${user.is_active === 't' ? "" : "un"}banUser('${user.id}')">${user.is_active === 't' ? "B" : "Unb"}an User</button>
                            </div>
                            `;

            })

    }
    const banUser = (id) => {
        const url = "/backend/api/bubbly/ban_user.php?id=" + id;
        fetch(url)
            .then(res => res.text())
            .then(async (user) => {
                document.getElementById('modal').innerHTML = "";
                openModal(id);
            });
    }
    const unbanUser = (id) => {
        const url = "/backend/api/bubbly/unban_user.php?id=" + id;
        fetch(url)
            .then(res => res.text())
            .then(async (user) => {
                document.getElementById('modal').innerHTML = "";
                openModal(id);
            });
    }
    window.openModal = openModal;
    window.banUser = banUser;
    window.unbanUser = unbanUser;
    window.loadUser = loadUser;
    window.searchUser = loadUserBySearch;
    window.onload = () => {
        loadUser(0, 10);
    }
}