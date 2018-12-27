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
            # self.conn = sqlite3.connect('db/padmonster.sqlite3')
            self.conn = sqlite3.connect("/Users/erlisuo/practice/padguide/spider/padmonster/db/padmonster.sqlite3")
            self.awokenSkillDic = {}
            sql = "select AwokenSkillName, AwokenSkillId from AwokenSkill;"
            awokenSkills = self.query(sql)
            for pair in awokenSkills:
                # print(pair)
                self.awokenSkillDic[pair[0]] = pair[1]
            # print(awokenSkills)
        except Error as e:
            print("error message: " + e)
        # finally:
        #     print("closing connection")
        #     self.conn.close()
    def query(self, sql):
        cur = self.conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        return rows

    def insert(self, sql, obj):
        cur = self.conn.cursor()
        cur.execute(sql, obj)
        last_id = cur.lastrowid
        print("last row id: " + str(last_id))
        self.conn.commit()
        return last_id


    def is_monster(self, id):
        sql = "select * from Monster where MonsterId = " + str(id)
        rows = self.query(sql)
        if len(rows) > 0:
            return True
        return False


    def process_item(self, item, spider):
        print("processing item: ")
        print(item["name"])
        try:
            if self.is_monster(item["monster_id"]):
                print("found Monster")
            else:
                print("Cannot find monster, insert")
                awokenSkills = item["awaken_skills"]
                position = 0
                for skill in awokenSkills:
                    activeSkillId = self.awokenSkillDic[skill]
                    # sql = "select Id from AwokenSkillRelation where MonsterId = " +item["monster_id"] + " and AwokenSkillId = " + item[activeSkillId]
                    # existingId = self.query(sql)
                    # if existingId != None :
                    sql = "insert into AwokenSkillRelation (MonsterId, AwokenSkillId, Position) \
                    values (?,?,?);"
                    obj = (item["monster_id"], activeSkillId, position)
                    id = self.insert(sql, obj)
                    position = position + 1


                sql = "insert into Monster \
                (MonsterId, Name, MainAtt, SubAtt, LvMax, \
                Hp, Atk, Rec, Hp110, Atk110, \
                Rec110, ActiveSkillId, LeaderSkillId, MonsterIconPath) \
                values (?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                obj = (item["monster_id"], item["name"], item["main_attr"], item["sub_attr"], 99, item["hp_lv_max"], item["atk_lv_max"], item["rec_lv_max"], item["hp_110"], item["atk_110"], item["rec_110"], None, None, "test path")
                id = self.insert(sql, obj)


        except Error as e:
            print("error message: ")
            print(e)
        # finally:
        #     print("failed to execute: "+sql)

        return item
