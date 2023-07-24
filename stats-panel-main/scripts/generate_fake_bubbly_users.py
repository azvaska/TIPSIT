
import psycopg2
from faker import Faker
from utils import users

import random


def random_phone_num_generator():
    first = str(random.randint(300, 399))
    second = str(random.randint(1000000, 9999999))
    return '{}{}'.format(first, second)


conn = psycopg2.connect(
    host="localhost",
    database="bubbly",
    user="postgres",
    password="12345")

amount = 0
total = len(users)

for user in users:
    if (amount % 100 == 0):
        t
        print()
    fake = Faker()
    query = f"""
    INSERT INTO public.user (is_superuser,is_verified,id, email, hashed_password, is_active, username, name, surname, phone, is_phone_verified, is_email_verified, birth_date, gender, bio)
    VALUES (FALSE,TRUE,'{user}','{fake.email()}','{fake.password()}',TRUE,'{fake.user_name()}','{fake.first_name()}','{fake.last_name()}','{random_phone_num_generator()}',TRUE,TRUE,'{fake.date_of_birth()}','M','sdasda')
    """
    # print (query)
    try:
        cur = conn.cursor()
        a = cur.execute(query)
    except:
        continue
conn.commit()
