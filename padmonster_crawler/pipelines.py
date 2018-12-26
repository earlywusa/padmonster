# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html
import sqlite3
from sqlite3 import Error

class PadmonsterPipeline(object):
    def __init__(self):
        try:
            print("initialize connection")
            self.conn = sqlite3.connect('db/padmonster.sqlite3')
        except Error as e:
            print(e)
        finally:
            print("closing connection")
            self.conn.close()


    def process_item(self, item, spider):
        print("processing item: ")
        print(item)
        try:
            sql = ".schema"
            cur = self.conn.cursor()
            cur.execute(sql)
            rows = cur.fetchall()
            for row in rows:
                print(row)
        except Error as e:
            print(e)
        finally:
            print("failed to execute {}".format(sql))

        return item
