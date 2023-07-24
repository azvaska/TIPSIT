from utils import get_database_mongo, get_database_mysql
import bson
import datetime
import sys
import utils
from geopy import distance
import concurrent.futures
dbname = get_database_mongo()
positions = dbname["positions"]
mydb = get_database_mysql()
mydb.autocommit=True

mycursor = mydb.cursor()

timestamp = datetime.datetime.now()

# utils.init_average_user()
# # exit(0)
# # if (len(sys.argv) < 2):
# #     print("Usage: python3 calculate_average_travel.py <all|today>")
# #     exit(1)
# # if (sys.argv[1] == "all"):
# start_time = datetime.datetime.strptime("2020-01-01", '%Y-%m-%d')
# end_time = datetime.datetime.utcnow() + datetime.timedelta(days=367)

# else:

# start_time = datetime.datetime.utcnow() - datetime.timedelta(days=1)
# end_time = datetime.datetime.utcnow()
start_time = datetime.datetime.strptime("2020-01-01", '%Y-%m-%d')
end_time = datetime.datetime.utcnow() + datetime.timedelta(days=367)

query = bson.son.SON({'timestamp': {'$gte': start_time, '$lte': end_time}})


def distance_earth(lon1, lat1, lon2, lat2):
    return distance.distance((lat1, lon1), (lat2, lon2)).km


positions_per_user = {}

for x in positions.find(query):
    if x['user_id'] not in positions_per_user:
        positions_per_user[x['user_id']] = [x['geo_point']['coordinates']]
    else:
        positions_per_user[x['user_id']].append(x['geo_point']['coordinates'])


def calculate_distance(user_id, positions):
    dist = 0
    for i in range(len(positions)-1):
        dist += distance_earth(positions[i][0], positions[i][1],
                               positions[i+1][0], positions[i+1][1])
    return (user_id, dist)
# calculate average distance per user

with concurrent.futures.ThreadPoolExecutor() as executor:
    futures = []
    for key, value in positions_per_user.items():
        future = executor.submit(calculate_distance, key, value)
        futures.append(future)
    k = 0
    for future in concurrent.futures.as_completed(futures):
        result = future.result()
        k += 1
        user_id, dist = result
        print(k, user_id, dist)
        try:
            mycursor.execute(
                "UPDATE avgtravel SET average = %s,timedate = NOW() where user_id = UUID_TO_BIN(%s)", (dist, user_id))
            mydb.commit()
        except Exception as e:
            import traceback
            traceback.print_exc()
            print("Error")
mydb.commit()
# select BIN_TO_UUID(user_id) from avgtravel;
# random tra 500 utenti
