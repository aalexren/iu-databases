from pymongo import MongoClient

client = MongoClient('mongodb://localhost')

db = client['testrestaurants']

import datetime

def ex1():
    print('Find restaurants with Indian cuisine:')
    cursor = db.restaurants.find({'cuisine':'Indian'})

    for _ in cursor:
        print(f"{_['name']} : {_['cuisine']}")
    print('---------------------------------------------')

    print('Find restaurants with Indian or Thai cuisine')
    cursor = db.restaurants.find({'cuisine': {"$in": ['Indian', 'Thai']}})

    for _ in cursor:
        print(f"{_['name']} : {_['cuisine']}")
    print('---------------------------------------------')

    print('Find restaurant with the following address:')
    cursor = db.restaurants.find({'address.building': '1115', 'address.street': 'Rogers Avenue', 'address.zipcode': '11226'})

    for _ in cursor:
        print(f"{_['name']} : {_['address']}")
    print('---------------------------------------------')

def ex2():
    print('Insert restaurant into database')
    
    stime = '01/10/2014'
    date = datetime.datetime.strptime(stime, "%d/%m/%Y").timestamp()

    result = db.restaurants.insert_one(
        {
            'address': {'building':'1480', 'coord':[-73.9557413, 40.7720266], 'street':'2 Avenue', 'zipcode':'10075'},
            'borough':'Manhattan',
            'cuisine':'Italian',
            'name':'Vella',
            'restaurant_id':'41704620',
            'grades':[{'date':{'$date':date}, 'grade':'A', 'score':'11'}]
        }
    )

    print(result.inserted_id)

def ex3():
    print('Delete single Manhattan located restaurant')
    cursor = db.restaurants.find_one({'borough':'Manhattan'})
    print(cursor)
    result = db.restaurants.delete_one({'borough':'Manhattan'})
    print(result.deleted_count)

    print('Delete from database all Thai cuisine')
    result = db.restaurants.delete_many({'cuisine':'Thai'})
    print(result.deleted_count)

def ex4():
    pass

if __name__ == '__main__':
    ex1()
    ex2()
    ex3()
    ex4()
