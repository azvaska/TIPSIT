# from faker import Faker
import math
from multiprocessing import Pool,Semaphore
import multiprocessing
import threading
import numpy as np
import sys
import random
import datetime
from pymongo import MongoClient
from geopy import distance
from utils import users, get_database_mongo
import osmnx as ox
from shapely.geometry import LineString, MultiLineString

ox.config(use_cache=True)
start_date = datetime.datetime(2023, 1, 1)

minutes_in_8_hours = 8 * 60

amount_of_data = minutes_in_8_hours / 5

start = []
veneto_bounds = {
    'min_lat': 45.3851,
    'max_lat': 46.6729,
    'min_lon': 10.0431,
    'max_lon': 13.0742
}

venice_bounds = {
    'min_lat': 45.4095,
    'max_lat': 45.4505,
    'min_lon': 12.2725,
    'max_lon': 12.3548
}

mu = 9
sigma = 8


def generate_random_point():
    lat = random.uniform(veneto_bounds['min_lat'], veneto_bounds['max_lat'])
    lon = random.uniform(veneto_bounds['min_lon'], veneto_bounds['max_lon'])
    return lat, lon


def generateHome():
    # circle coords
    # radius = 1
    # r = radius * math.sqrt(random.uniform(0, 1))
    # theta = random.uniform(0, 1) * 2 * math.pi

    # lat = central_point[0] + r * math.cos(theta)
    # lng = central_point[1] + r * math.sin(theta)
    lat, lng = generate_random_point()

    date = start_date + datetime.timedelta(days=random.randint(0, 365), 
                                           hours=random.randint(1, 8))
    return date, lat, lng


def get_distance(start, end):
    return distance.distance(start, end).km


def generate_intermediary_points(lat1, lon1, lat2, lon2, step_distance=0.25):
    distance = get_distance((lat1, lon1), (lat2, lon2))

    if distance <= 0.1:
        return [(lat1, lon1), (lat2, lon2)]

    num_intermediary_points = int(distance / step_distance)
    lat_step = (lat2 - lat1) / (num_intermediary_points + 1)
    lon_step = (lon2 - lon1) / (num_intermediary_points + 1)

    intermediary_points = [(lat1, lon1)]
    for i in range(1, num_intermediary_points + 1):
        lat = lat1 + i * lat_step
        lon = lon1 + i * lon_step
        intermediary_points.append((lat, lon))

    intermediary_points.append((lat2, lon2))
    return intermediary_points


def test_home():
    data = []
    while True:
        date, lat_o, lng_o = generateHome()

        dist = random.gammavariate(mu, sigma) / 100
        # total_distance = get_distance((lat_o,lng_o), (lat_e,lng_e))
        lat_e = lat_o + dist * math.cos(random.uniform(0, 1) * 2 * math.pi)
        lng_e = lng_o + dist * math.sin(random.uniform(0, 1) * 2 * math.pi)

        print("START", lat_o, ",", lng_o, end=" -> ")
        print("END", lat_e, ",", lng_e)
        # check if lat_e, lng_e is in veneto
        if (lat_e < veneto_bounds['min_lat'] or lat_e > veneto_bounds['max_lat'] or lng_e < veneto_bounds['min_lon'] or lng_e > veneto_bounds['max_lon']):
            print("NOT IN VENETO")
        else:
            return []


def generateData(user_id, G2, edges):
    data = []
    while True:
        date, lat_o, lng_o = generateHome()

        dist = random.gammavariate(mu, sigma)

        lat_e = lat_o + dist * math.cos(random.uniform(0, 1) * 2 * math.pi)
        lng_e = lng_o + dist * math.sin(random.uniform(0, 1) * 2 * math.pi)

        if (lat_e < veneto_bounds['min_lat'] or lat_e > veneto_bounds['max_lat'] or lng_e < veneto_bounds['min_lon'] or lng_e > veneto_bounds['max_lon']):
            pass
        else:
            break
    print(date.strftime("%Y-%m-%d %H:%M:%S")),

    origin_node = ox.distance.nearest_nodes(G2, lng_o, lat_o)
    destination_node = ox.distance.nearest_nodes(G2, lng_e, lat_e)
    try:
        route = ox.shortest_path(G2, origin_node, destination_node, cpus=None)
        #print("ROUTE Calculated", user_id)
        if (route is None):
            raise Exception("ROUTE IS NONE")
    except:
        return []
    data.append({
        "user_id": user_id,
        "geo_point": {
            "type": "point",
            "coordinates": [lng_o, lat_o],
        }, "timestamp": date})
    route_pairwise = zip(route[:-1], route[1:])

    dist_in_5_min = 0.5

    lines = [edges.loc[uv, 'geometry'].iloc[0] for uv in route_pairwise]
    lines_multi = [list(cord.coords)
                   for cord in list(MultiLineString(lines).geoms)]

    prev_coord = []
    last_saved = []

    for line in lines_multi:
        for coord in line:
            coord = (coord[0] + random.uniform(-0.0001, 0.0001),
                     coord[1] + random.uniform(-0.0001, 0.0001))

            if len(prev_coord) > 1:
                if get_distance(prev_coord, coord) < dist_in_5_min:
                    continue

                points = generate_intermediary_points(
                    *prev_coord, *coord, step_distance=dist_in_5_min/2)
                for x in points:
                    data.append({
                        "user_id": user_id,
                        "geo_point": {
                            "type": "point",
                            "coordinates": x,
                        }, "timestamp": date})
                    date += datetime.timedelta(
                        seconds=random.randint(120, 180))
            else:
                data.append({
                    "user_id": user_id,
                    "geo_point": {
                        "type": "point",
                        "coordinates": coord,
                    }, "timestamp": date})
                date += datetime.timedelta(seconds=random.randint(240, 360))

            prev_coord = coord

    return data


def insert_documents(user_id):
    # test_home()
    print(shared_graph)
    data = generateData(user_id, shared_graph, shared_edges)
    if (len(data) == 0):
        pass
    else:
        print("INSERTING", user_id)
        shared_collection.insert_many(data)


    return user_id
def main(moove=False):
    #G2 = ox.load_graphml('/var/www/html/scripts/Veneto.graphml')
    G2 = ox.load_graphml('/var/www/html/scripts/venice.graphml')
    edges = ox.graph_to_gdfs(G2, nodes=False).sort_index()

    dbname = get_database_mongo()
    collection_name = dbname["positions"]
    #res = collection_name.delete_many({})
    #print(res.deleted_count, " documents deleted.")
    tasks = []
    
    with multiprocessing.Pool(3, initializer=init_process, initargs=(G2, edges,collection_name)) as pool:
        results = pool.map(insert_documents, random.choices(users, k=random.randint(5, 10)) if moove else users)

    # for id, user_id in enumerate(users):
    #     thread = threading.Thread(target=insert_documents, args=(semaphore,
    #                     collection_name, user_id, G2, edges))
    #     thread.start()
    #     tasks.append(thread)

    # for task in tasks:
    #     task.join()


# Shared variables
shared_graph = None
shared_edges = None
shared_collection = None

def init_process(graph, edges,collection):
    global shared_graph, shared_edges,shared_collection
    shared_collection = collection
    shared_graph = graph
    shared_edges = edges

if __name__ == '__main__':
    if (len(sys.argv) > 1):
        if (sys.argv[1] == "moove"):
            main(moove=True)
    else:
        main()
# print(generateData())

# plot the data

# import matplotlib.pyplot as plt

# data = generateData()

# lat = [x[0] for x in data]
# lng = [x[1] for x in data]
# date = [x[2] for x in data]

# plt.plot(lat, lng)
# plt.show()
