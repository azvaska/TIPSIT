
console.log(ol)
var Map = ol.Map;
var View = ol.View;
var KML = ol.format.KML;

var Circle = ol.style.Circle;
var Fill = ol.style.Fill;
var Stroke = ol.style.Stroke;
var Style = ol.style.Style;
var HeatmapLayer = ol.layer.Heatmap;
var TileLayer = ol.layer.Tile;
var Feature = ol.Feature;
var VectorLayer = ol.layer.Vector;
// var Circle = ol.Circle;

var Stamen = ol.source.Stamen;
var Modify = ol.interaction.Modify;
var Snap = ol.interaction.Snap;
var OSM = ol.source.OSM;

var GeoJSON = ol.format.GeoJSON;
console.log(GeoJSON);
var Vector = ol.source.Vector;
// import KML from 'ol/format/KML.js';
// import Map from 'ol/Map.js';
// import Stamen from 'ol/source/Stamen.js';
// import Vector from 'ol/source/Vector.js';
// import View from 'ol/View.js';
// import { Heatmap as HeatmapLayer, Tile as TileLayer } from 'ol/layer.js';

const blur = document.getElementById('blur');
const radius = document.getElementById('radius');
const image = new Circle({
    radius: 10,
    fill: null,
    stroke: new Stroke({ color: 'red', width: 1 }),
});

const myStyle = {
    "color": "#ff7800",
    "weight": 5,
    "opacity": 0.65
};

function transform(lng, lat) {
    return ol.proj.transform([lat, lng], 'EPSG:4326', 'EPSG:3857');
}

function markAllPositions() {
    fetch('/backend/api/position/get_all_positions.php')
        .then(res => res.json())
        .then(data => {
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
                        "coordinates": [line.lng, line.lat],
                    };
                })
            };

            // QUESTO PER COLLEGARE I PUNTI CON DELLE LINEE
            // let lines = [];
            // for (let i = 0; i < data.length - 1; ++i) {
            //     lines.push({
            //         'type': 'Feature',
            //         'geometry': {
            //             'type': 'LineString',
            //             'coordinates': [[data[i].lng, data[i].lat], [data[i + 1].lng, data[i + 1].lat]],
            //         },
            //     })
            // }
            // let obj = {
            //     'type': 'FeatureCollection',
            //     'crs': {
            //         'type': 'name',
            //         'properties': {
            //             'name': 'EPSG:4326',
            //         },
            //     },
            //     'features': lines
            // };

            console.log(obj);

            const vector = new Vector({
                features: new GeoJSON().readFeatures(obj),
            });
            const styles = {
                'Point': new Style({
                    image: image,
                }),
                'LineString': new Style({
                    stroke: new Stroke({
                        color: 'green',
                        width: 1,
                    })
                })
            }
            const styleFunction = (feature) => {
                return styles[feature.getGeometry().getType()];
            };

            const vectorLayer = new VectorLayer({
                source: vector,
                style: styleFunction,
            });

            const map = new Map({
                layers: [
                    new TileLayer({
                        source: new OSM(),
                    }),
                    vectorLayer,
                ],
                target: 'map',
                view: new View({
                    projection: 'EPSG:4326',
                    center: [0, 0],
                    zoom: 2,
                }),
            });

        });
}

markAllPositions();


//  geojsonObject["features"].map((obj) => {
//     console.log(obj);
//     obj["coordinates"] = transform(obj.coordinates[0],obj.coordinates[1]);
//     return obj;
//  } )


// const vector = new HeatmapLayer({
//     source: new Vector({
//         features: new GeoJSON().readFeatures(geojsonObject),
//     }),
//     blur: parseInt(blur.value, 10),
//     radius: parseInt(radius.value, 10),
//     weight: function (feature) {
//         // 2012_Earthquakes_Mag5.kml stores the magnitude of each earthquake in a
//         // standards-violating <magnitude> tag in each Placemark.  We extract it from
//         // the Placemark's name instead.
//         const name = feature.get('name');
//         const magnitude = parseFloat(1.2);
//         return magnitude - 5;
//     },
// });

// const raster = new TileLayer({
//     source: new Stamen({
//         layer: 'toner',
//     }),
// });

// new Map({
//     layers: [raster, vector],
//     target: 'map',
//     view: new View({
//         center: [0, 0],
//         zoom: 2,
//     }),
// });

// blur.addEventListener('input', function () {
//     vector.setBlur(parseInt(blur.value, 10));
// });

// radius.addEventListener('input', function () {
//     vector.setRadius(parseInt(radius.value, 10));
// });
