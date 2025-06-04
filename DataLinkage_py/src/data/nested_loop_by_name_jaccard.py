'''
Created on 1 May 2020

@author: shree

Modified by Zijian on Aug 2022
Modified by Andrew on May 2025
'''
import sys
sys.path.append('/home/s4828041/a2/a2t1/DataLinkage_py/')
import src.psql.DBconnect as db
import src.data.similarity as similarity
import src.data.csv_loader as csv
import src.data.measurement as measure

from src.data.restaurant import restaurant as res
import datetime


def nested_loop_by_name_jaccard(csv_path, benchmark_path, q, threshold):

    con = db.create_connection()
    cur = con.cursor()
    string_query = "SELECT * FROM RESTAURANT"
    cur.execute(string_query)
    restaurants=[]
    for rid ,name, address, city  in cur:
        restaurant = res()
        restaurant.set_id(rid)
        restaurant.set_name(name)
        restaurant.set_address(address)
        restaurant.set_city(city)
        restaurants.append(restaurant)
        
    cur.close()
    con.close()

    # restaurants = csv.csv_loader(csv_path)
    results = []
    restaurant1 = res()
    restaurant2 = res()
    id1 = 0
    id2 = 0
    name1 = None
    name2 = None
    start_time = datetime.datetime.now()
    for i in range(0, len(restaurants)):
        restaurant1 = restaurants[i]
        id1 = restaurant1.get_id()
        name1 = restaurant1.get_name()
        for j in range(i + 1, len(restaurants)):
            restaurant2 = restaurants[j]
            id2 = restaurant2.get_id()
            name2 = restaurant2.get_name()
            sim = similarity.calc_jaccard(name1, name2, q)
            if sim >= threshold:
                results.append(str(id1) + '_' + str(id2))

    end_time = datetime.datetime.now()
    time = end_time - start_time
    # print("Total Time:", round(time.total_seconds() * 1000, 3), 'milliseconds')
    print("Total number of similar records found with Jaccard Coefficient: ", len(results))
    benchmark = measure.load_benchmark(benchmark_path)
    measure.calc_measure(results, benchmark)


# End of function


# nested_loop_by_name_jaccard("/home/s4828041/a2/a2t1/DataLinkage_py/data/restaurant.csv", "/home/s4828041/a2/a2t1/DataLinkage_py/data/restaurant_pair.csv")
