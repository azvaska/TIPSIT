<?php
if ($_SESSION['isAdmin'] != "1") {
    echo "Forbidden";
    die();
}
?>

<script src="/w/w/w/js/admin.js" defer></script>

<script>
    loadCss("/w/w/w/css/admin.css");
</script>
<!-- Search bar -->
<div class="search-bar">
    <input type="text" placeholder="Search by username &#128269;" onkeyup="search()" id="input" />
</div>

<div class="pagination">
    <button id="backBtn" class="btn disabled">&lt;</button>
    <span id="pageNumber">1</span>
    <button id="forwardBtn" class="btn">&gt;</button>
</div>

<ul id="user-list"></ul>

<!-- Modal -->
<div id="modal" class="modal"></div>


<script>
    // Function to close the modal
    const modal = document.getElementById('modal');
    modal.addEventListener('click', event => {
        const rect = modal.querySelector('.modal-content').getBoundingClientRect();
        if (event.clientX >= rect.left && event.clientX <= rect.right && event.clientY >= rect.top && event.clientY <= rect.bottom) {
            // clicked inside the element
            return;
        }
        modal.style.display = 'none';
    });

    const backBtn = document.getElementById('backBtn');
    const forwardBtn = document.getElementById('forwardBtn');
    const pageNumberElement = document.getElementById('pageNumber');

    // Set initial page number
    let pageNumber = 1;
    pageNumberElement.textContent = pageNumber;

    // Add event listeners
    backBtn.addEventListener('click', () => {
        if (pageNumber > 1) {
            pageNumber--;
            pageNumberElement.textContent = pageNumber;
            forwardBtn.classList.remove('disabled');
            if (document.getElementById('input').value == "") {
                window.loadUser((pageNumber - 1) * 10, 10);
            } else {
                window.searchUser(document.getElementById('input').value, (pageNumber - 1) * 10, 10);
            }
        }
        if (pageNumber === 1) {
            backBtn.classList.add('disabled');
        }
    });

    forwardBtn.addEventListener('click', () => {
        pageNumber++;
        pageNumberElement.textContent = pageNumber;
        backBtn.classList.remove('disabled');

        if (document.getElementById('input').value == "") {
            window.loadUser((pageNumber - 1) * 10, 10);
        } else {
            window.searchUser(document.getElementById('input').value, (pageNumber - 1) * 10, 10);
        }
    });

    function search() {
        let filter
        let input = document.getElementById('input');
        filter = input.value.toUpperCase();
        pageNumber = 1;
        pageNumberElement.textContent = pageNumber;
        backBtn.classList.add('disabled');

        window.searchUser(filter, 0, 10);
    }
</script>