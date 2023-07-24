{
    let datepickerData = flatpickr("#datepickerData", {
        enableTime: true,
        mode: "range",
        dateFormat: "Y-m-d H:i",
        defaultDate: ["today", "today"],
    });

    // check the url parameters
    let urlParams = new URLSearchParams(window.location.search);
    let start = urlParams.get('start');
    let end = urlParams.get('end');

    if (start != null && end != null) {
        datepickerData.setDate([new Date(parseInt(start)), new Date(parseInt(end))]);
    }

    datepickerData.config.onClose.push((selectedDates) => {
        let start = parseInt(selectedDates[0].getTime());
        let end = parseInt(selectedDates[1].getTime());

        let urlParams = new URLSearchParams(window.location.search);
        let s = urlParams.get('start');
        let e = urlParams.get('end');
        if (s != null && e != null && s == start && e == end) {
            return;
        }
        let url = `/backend/api/position/get_used_hours.php?start=${start}&end=${end}`;
        window.location.href = `?start=${start}&end=${end}`;
    });

    const ctx = document.getElementById('chartData');

    let url = `/backend/api/position/get_used_hours.php`;
    if (start != null && end != null) {
        url += `?start=${start}&end=${end}`;
    }

    fetch(url)
        .then(res => res.json())
        .then(data => {
            let labels = [];
            for (let i = 0; i < data.length - 1; i++) {
                labels.push(`Hour ${i}-${i + 1}`);
            }

            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '# of data per hour',
                        data: data,
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        })
        .catch(e => {
            console.error(e);
        });
}