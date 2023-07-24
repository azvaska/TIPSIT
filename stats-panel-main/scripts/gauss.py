import random
import math

# Define the boundaries of Veneto region (latitude and longitude ranges)
veneto_bounds = {
    'min_lat': 45.3851,
    'max_lat': 46.6729,
    'min_lon': 10.0431,
    'max_lon': 13.0742
}

# Function to generate a random latitude and longitude point within Veneto
def generate_random_point():
    lat = random.uniform(veneto_bounds['min_lat'], veneto_bounds['max_lat'])
    lon = random.uniform(veneto_bounds['min_lon'], veneto_bounds['max_lon'])
    return lat, lon

# Function to calculate the Haversine distance between two points
def haversine_distance(lat1, lon1, lat2, lon2):
    R = 6371  # Radius of the Earth in kilometers

    # Convert coordinates to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    # Calculate differences
    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    # Calculate Haversine distance
    a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    distance = R * c

    return distance

# Generate two random points within Veneto
point1 = generate_random_point()
point2 = generate_random_point()

# Calculate the distance between the two points
distance = haversine_distance(point1[0], point1[1], point2[0], point2[1])

# Generate a random distance between the two points
random_distance = random.uniform(0, distance)

# Calculate the ratio to adjust the random distance within the available distance
ratio = random_distance / distance

# Calculate the coordinates of the random point based on the adjusted distance
lat_diff = point2[0] - point1[0]
lon_diff = point2[1] - point1[1]
random_point_lat = point1[0] + ratio * lat_diff
random_point_lon = point1[1] + ratio * lon_diff

# Print the generated points and the random distance
print("Random Point 1 (Latitude, Longitude):", point1)
print("Random Point 2 (Latitude, Longitude):", point2)
print("Random Distance:", random_distance)
print("Random Point with Adjusted Distance (Latitude, Longitude):", random_point_lat, random_point_lon)