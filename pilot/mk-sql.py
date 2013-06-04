import sqlite3
import sys

con = sqlite3.connect('./url-tms.sqlite')
cur = con.cursor()
cur.execute('create table timemaps (url text, filename text, exist integer, archive integer)')
con.commit()
con.close()
