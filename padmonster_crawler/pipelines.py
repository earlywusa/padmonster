# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html

from padmonster_crawler.models.monster import Monster
from padmonster_crawler.models.monster_handler import MonsterHandler
# from padmonster_crawler.items import PadmonsterItem

import traceback
import sys

class PadmonsterPipeline(object):

    def __init__(self):
        self.handler = MonsterHandler()

    def process_item(self, item, spider):
        print("processing item: ")
        print(item["name"])
        try:
            monster = Monster(item)

            self.handler.processMonster(monster)
        except Exception as e:
            print("pipeline: error message:")
            exc_type, exc_value, exc_tb = sys.exc_info()
            traceback.print_exception(exc_type, exc_value, exc_tb)
            print(e)

        return item
