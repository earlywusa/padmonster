import sqlite3
from sqlite3 import Error

import traceback
import sys

class MonsterHandler(object):
    """docstring for MonsterHandler."""
    conn = None
    awokenSkillDic = {}
    activeSkillDic = {}
    leaderSkillDic = {}
    def __init__(self):
        try:
            print("initialize connection")
            # self.conn = sqlite3.connect('db/padmonster.sqlite3')
            self.conn = sqlite3.connect("/Users/erlisuo/practice/padguide/spider/padmonster/db/padmonster.sqlite3")
            # self.awokenSkillDic = {}
            self.fetchAwokenSkill()
            self.fetchActiveSkill()
            self.fetchLeaderSkill()
        except Error as e:
            print("error message: " + e)

    def fetchAwokenSkill(self):
        sql = "select AwokenSkillName, AwokenSkillId from AwokenSkill;"
        awokenSkills = self.query(sql)
        for pair in awokenSkills:
            # print(pair)
            self.awokenSkillDic[pair[0]] = pair[1]

    def fetchActiveSkill(self):
        sql = "select ActiveSkillName, ActiveSkillId from ActiveSkill;"
        activeSkills = self.query(sql)
        for pair in activeSkills:
            print(pair)
            self.activeSkillDic[pair[0]] = pair[1]

    def fetchLeaderSkill(self):
        sql = "select LeaderSkillName, LeaderSkillId from LeaderSkill;"
        leaderSkills = self.query(sql)
        for pair in leaderSkills:
            print(pair)
            self.leaderSkillDic[pair[0]] = pair[1]


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

    def isExist(self, id):
        #move to monster class later
        sql = "select * from Monster where MonsterId = " + str(id)
        rows = self.query(sql)
        if len(rows) > 0:
            return True
        return False

    def processMonster(self, monster):
        try:
            if self.isExist(monster.id):
                print("found Monster")
                #if different update
            else:
                print("Cannot find monster, insert")
                lastRowId = monster.insert(self)
        except Error as e:
            print("error message: ")
            exc_type, exc_value, exc_tb = sys.exc_info()
            traceback.print_exception(exc_type, exc_value, exc_tb)
            print(e)
