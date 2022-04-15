import psycopg2
from geopy.geocoders import Nominatim
import time

def get_addresses():
    conn = None
    ret = []
    try:
        conn = psycopg2.connect(host='localhost',
                                database='dvdrental',
                                user='postgres',
                                password='proof')
        cur = conn.cursor()
        cur.callproc('retrieve_addresses', ())
        row = cur.fetchone()
        while row is not None:
            ret.append(row)
            print(row)
            row = cur.fetchone()
        return ret
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

def update_coords(addresses: list):
    geolocator = Nominatim(user_agent='database', timeout=3)
    conn = None
    try:
        conn = psycopg2.connect(host='localhost',
                                database='dvdrental',
                                user='postgres',
                                password='proof')
        conn.autocommit = True
        cur = conn.cursor()
        for address in addresses:
            location = geolocator.geocode(address[1])
            if location is not None:
                cur.execute('UPDATE address SET longitude=%s, latitude=%s WHERE address_id=%s;', (location.longitude, location.latitude, address[0]))
                # conn.commit()
                print(location.latitude, location.longitude)
            else:
                cur.execute('UPDATE address SET longitude=%s, latitude=%s WHERE address_id=%s;', (0.0, 0.0, address[0]))
                print((0, 0))
            # conn.commit()
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()


if __name__ == '__main__':
    addresses = get_addresses()
    update_coords(addresses)
