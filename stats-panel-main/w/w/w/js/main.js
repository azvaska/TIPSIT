// @ts-nocheck
fetch('/backend/api/position/get_users_positions.php?limit=15')
    .then(res => res.json())
    .then(async (d) => {
        //call the bubbly api to get from the userid to the username
        await fetch('/backend/api/bubbly/get_users.php?id=' + d.map(line => line[0]).join(','))
            .then(res => res.json())
            .then(value => { d = d.map((line, index) => [value[index].username, line[1]]) })
            .catch(err => console.log(err));


        // data: user, count
        const data = {
            labels: d.map(line => line[0]),
            datasets: [{
                axis: 'y',
                label: 'Amount of positions',
                data: d.map(line => line[1]),
                fill: false,
                borderWidth: 1
            }]
        };

        const config = {
            type: 'bar',
            data,
            options: {
                indexAxis: 'y',
            }

        };

        const ctx = document.getElementById('utenti');

        new Chart(ctx, config);
    });


let cpu_values = [];
let cpu_seconds = [];
let pie_memory = [];

const max_cpu_data = 27;

const cpu_ctx = document.getElementById('cpu');
const pie_ctx = document.getElementById('memory');
const ram_ctx = document.getElementById('ram');

const dataset = new Chart(cpu_ctx, {
    type: 'line',
    data: {
        labels: [],
        datasets: [{
            label: 'CPU usage',
            data: cpu_values,
            fill: true,
            borderWidth: 1,
            tension: 0.2
        }]
    },
    options: {
        scales: {
            y: {
                beginAtZero: true,
                max: 100
            },
        }
    }
});
const piechart = new Chart(pie_ctx, {
    type: 'pie',
    data: {
        labels: [],
        datasets: [{
            label: 'Memory',
            data: pie_memory,
            backgroundColor: ['#23ce31', '#cfbc0a', '#cf580a', '#f1f00b', '#0b76f1']
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'top',
            },
            title: {
                display: true,
                text: 'Memory'
            }
        }
    }
});

const ramchart = new Chart(ram_ctx, {
    type: 'pie',
    data: {
        labels: [],
        datasets: [{
            label: 'Ram usage',
            data: [],
            backgroundColor: ['#d84040', '#3c3c3c']
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'top',
            },
            title: {
                display: true,
                text: 'Ram'
            }
        }
    },

});

let amount = 0;
const delay = 1000;

function getCpu() {
    fetch('/backend/api/cpu.php')
        .then(res => res.json())
        .then(value => {
            let seconds = (new Date()).getSeconds();

            if (amount < max_cpu_data) {
                if (amount == 0) {
                    piechart.data.labels = ['Used', 'Free', 'Shared', 'Cached', 'Available'];

                    ramchart.data.labels = ['Used', 'Free'];
                }

                cpu_values.push(value.cpu);
                cpu_seconds.push(seconds);

                dataset.data.labels = cpu_seconds;
                dataset.data.datasets[0].data = cpu_values;

                ++amount;
            } else {
                // remove the first element
                for (let i = 1; i < cpu_values.length; i++) {
                    cpu_values[i - 1] = cpu_values[i];
                    cpu_seconds[i - 1] = cpu_seconds[i];
                }

                cpu_values[cpu_values.length - 1] = value.cpu;
                cpu_seconds[cpu_seconds.length - 1] = seconds;
                dataset.data.labels = cpu_seconds;
                dataset.data.datasets[0].data = cpu_values;
            }

            pie_memory = [value.memused, value.memfree, value.memshared, value.memcached, value.memavailable];
            piechart.data.datasets[0].data = pie_memory;

            ramchart.data.datasets[0].data = [value.ram, 100 - value.ram];

            ramchart.update();
            piechart.update();
            dataset.update();
            setTimeout(getCpu, delay);
        });
}

getCpu();
