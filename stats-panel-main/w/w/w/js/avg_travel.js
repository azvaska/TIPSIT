{
    const url = `/backend/api/position/get_average_travel.php`;

    const ctx = document.getElementById('chartavg_travel');

    fetch(url)
        .then(res => res.json())
        .then(data => {
            // get max value
            // let max = 0;
            // for (let i = 0; i < data.length; i++) {
            //     let value = Math.floor(Object.values(data[i])[0]);
            //     if (value > max) {
            //         max = value;
            //     }
            // }    

            let amount_of_lines = 100;
            let values = Array(amount_of_lines).fill(0);

            // calculate median

            let all_data = Array(data.length);

            for (let i = 0; i < data.length; i++) {
                // let index = Math.floor(Object.values(data[i])[0] * 100 / max);
                // if (index >= amount_of_lines) {
                //     index = amount_of_lines - 1;
                // }
                // values[index]++;
                all_data[i] = Math.floor(Object.values(data[i])[0]);
            }

            // find median value

            // sort all_data
            all_data.sort((a, b) => (a - b));
            let size = all_data.length;
            // let median = (all_data[Math.floor(size / 2) - 1] + all_data[Math.floor(size / 2)]) / 2;
            let median = 20;

            // graph only on median values

            // let multiply = median;
            let multiply = 1;

            for (let i = 0; i < data.length; i++) {
                let index = Math.floor(all_data[i] * multiply / median);
                if (index > amount_of_lines) {
                    index = amount_of_lines - 1;
                    // break;
                }
                values[index]++;
            }

            let labels = [];
            for (let i = 0; i < amount_of_lines; i++) {
                labels.push(`> ${i * median / multiply} km`);
            }

            new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: labels,
                    datasets: [{
                        label: '# of data per km travelled',
                        data: values,
                        borderWidth: 1
                    }]
                },
                options: {
                    scales: {
                        y: {
                            beginAtZero: true,
                            autoSkip: true,
                        }
                    }
                }
            });
        })
        .catch(console.error);
}