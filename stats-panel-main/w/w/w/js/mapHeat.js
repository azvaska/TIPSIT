{
    let Map = ol.Map;
    let View = ol.View;
    let Stamen = ol.source.Stamen;
    let XYZ = ol.source.XYZ;
    let VectorSource = ol.source.Vector;
    let HeatmapLayer = ol.layer.Heatmap;
    let TileLayer = ol.layer.Tile;
    let GeoJSON = ol.format.GeoJSON;
    let bbox = ol.loadingstrategy.bbox;

    const blur = document.getElementById('blur');
    const radius = document.getElementById('radius');

    function transform(coords) {
        return ol.proj.transform([coords[1], coords[0]], 'EPSG:4326', 'EPSG:3857');
    }

    let datepickerHeatMap = flatpickr("#datepickerHeatMap", {
        enableTime: true,
        mode: "range",
        dateFormat: "Y-m-d H:i",
        defaultDate: ["today", "today"],
    });

    let urlParams = new URLSearchParams(window.location.search);
    let start = urlParams.get('start');
    let end = urlParams.get('end');
    if (start != null && end != null) {
        datepickerHeatMap.setDate([new Date(parseInt(start)), new Date(parseInt(end))]);
    }

    let dataHeatMap = [];

    datepickerHeatMap.config.onClose.push((selectedDates) => {
        let start = parseInt(selectedDates[0].getTime());
        let end = parseInt(selectedDates[1].getTime());

        let urlParams = new URLSearchParams(window.location.search);
        let s = urlParams.get('start');
        let e = urlParams.get('end');

        if (s != null && e != null && s == start && e == end) {
            return;
        }

        let url = `/backend/api/position/get_user_positions.php?start=${start}&end=${end}`;
        if (find_user.value === 'on') {
            url += `&user_id=${document.getElementById('userid').value}`;
        }

        fetch(url).then(res => res.json()).then(data => {
            dataHeatMap = data;
            document.getElementById('amount').innerText = data.length;
            let obj = {
                'type': 'FeatureCollection',
                'crs': {
                    'type': 'name',
                    'properties': {
                        'name': 'EPSG:4326',
                    },
                },
                'features': data.map(line => {
                    return {
                        "type": "Point",
                        "coordinates": transform([line[0], line[1]]),
                    };
                })
            };
            const features = vectorSource.getFormat().readFeatures(obj);
            vectorSource.clear();
            vectorSource.addFeatures(features);
        });

        // window.location.href = `?start=${start}&end=${end}`;

    });

    const find_user = document.getElementById('find_user');


    const vectorSource = new VectorSource({
        format: new GeoJSON(),
        loader: (extent, resolution, projection, success, failure) => {
            // check the url parameters
            let urlParams = new URLSearchParams(window.location.search);
            let start = urlParams.get('start');
            let end = urlParams.get('end');

            let url = '/backend/api/position/get_user_positions.php';

            if (start != null && end != null) {
                url += `?start=${start}&end=${end}`;
                if (find_user.value === 'on') {
                    url += `&user_id=${document.getElementById('userid').value}`;
                }
            } else {
                if (find_user.value === 'on') {
                    url += `?user_id=${document.getElementById('userid').value}`;
                }
            }


            const xhr = new XMLHttpRequest();
            xhr.open('GET', url);
            const onError = () => {
                vector.removeLoadedExtent(extent);
                failure();
            }

            xhr.onerror = onError;
            xhr.onload = () => {
                dataHeatMap = JSON.parse(xhr.responseText);
                document.getElementById('amount').innerText = dataHeatMap.length;
                // let randomuser = data[Math.floor(Math.random() * data.length)].userid;
                // let oneuser = data.filter(data => data.userid == randomuser);
                if (xhr.status == 200) {
                    let obj = {
                        'type': 'FeatureCollection',
                        'crs': {
                            'type': 'name',
                            'properties': {
                                'name': 'EPSG:4326',
                            },
                        },
                        'features': dataHeatMap.map(line => {
                            return {
                                "type": "Point",
                                "coordinates": transform([line[0], line[1]]),
                            };
                        })
                    };
                    const features = vectorSource.getFormat().readFeatures(obj);
                    vectorSource.addFeatures(features);
                    success(features);
                } else {
                    onError();
                }
            }
            xhr.send();
        },
        strategy: bbox,
    });

    const vector = new HeatmapLayer({
        source: vectorSource,
        blur: parseInt(blur.value, 10),
        radius: parseInt(radius.value, 10),
    });


    let raster = new TileLayer({
        source: new Stamen({
            layer: 'terrain',
        })
    });

    let map = new Map({
        layers: [raster, vector],
        target: 'map',
        view: new View({
            center: transform([41.2925, 12.5736]),
            zoom: 2,
        }),
    });

    blur.addEventListener('input', () => {
        vector.setBlur(parseInt(blur.value));
    });

    radius.addEventListener('input', () => {
        vector.setRadius(parseInt(radius.value));
    });

    map.on('moveend', () => {
        let zoom = map.getView().getZoom();
        let radiusValue = parseInt(radius.value);
        vector.setRadius(radiusValue * zoom / 9);
    });

    const admin_user = document.querySelector('#userid');
    const admin_button = document.querySelector('#find');

    admin_button.addEventListener('click', async () => {
        let obj = {};
        if (admin_user.value == '') {
            document.getElementById('amount').innerText = dataHeatMap.length;
            obj = {
                'type': 'FeatureCollection',
                'crs': {
                    'type': 'name',
                    'properties': {
                        'name': 'EPSG:4326',
                    },
                },
                'features': dataHeatMap.map(line => {
                    return {
                        "type": "Point",
                        "coordinates": transform([line[0], line[1]]),
                    };
                })
            };
        } else {
            let urlParams = new URLSearchParams(window.location.search);
            let s = urlParams.get('start');
            let e = urlParams.get('end');
            if (s === null && e === null) {
                s = datepickerHeatMap.selectedDates[0].getTime();
                e = datepickerHeatMap.selectedDates[1].getTime();
            }
            let url = `/backend/api/position/get_user_positions.php?start=${s}&end=${e}&user_id=${admin_user.value}`;

            await fetch(url).then(res => res.json()).then(data => {
                dataHeatMap = data;
                if (data.length == 0) {
                    alert('No data found for this user');
                    return;
                }
                document.getElementById('amount').innerText = data.length;
                obj = {
                    'type': 'FeatureCollection',
                    'crs': {
                        'type': 'name',
                        'properties': {
                            'name': 'EPSG:4326',
                        },
                    },
                    'features': data.map(line => {
                        return {
                            "type": "Point",
                            "coordinates": transform([line[0], line[1]]),
                        };
                    })
                };

            });
            console.log(obj);
            const features = vectorSource.getFormat().readFeatures(obj);
            vectorSource.clear();
            vectorSource.addFeatures(features);

        }
    });
}