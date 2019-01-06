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
    monsterTypeDic = {}
    def __init__(self):
        try:
            print("initialize connection")
            self.conn = sqlite3.connect('db/padmonster.sqlite3')
            # self.conn = sqlite3.connect("/Users/erlisuo/practice/padguide/spider/padmonster/db/padmonster.sqlite3")
            # self.awokenSkillDic = {}
            self.fetchAwokenSkill()
            self.fetchActiveSkill()
            self.fetchLeaderSkill()
            self.fetchMonsterType()
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
            # print(pair)
            self.activeSkillDic[pair[0]] = pair[1]

    def fetchLeaderSkill(self):
        sql = "select LeaderSkillName, LeaderSkillId from LeaderSkill;"
        leaderSkills = self.query(sql)
        for pair in leaderSkills:
            # print(pair)
            self.leaderSkillDic[pair[0]] = pair[1]

    def fetchMonsterType(self):
        sql = "select TypeName, TypeId from Type;"
        types = self.query(sql)
        for pair in types:
            self.monsterTypeDic[pair[0]] = pair[1]

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

    def update(self, sql, obj):
        cur = self.conn.cursor()
        cur.execute(sql, obj)
        self.conn.commit()

    def processMonster(self, monster):
        try:
            lastRowId = monster.update(self)
        except Error as e:
            print("error message: ")
            exc_type, exc_value, exc_tb = sys.exc_info()
            traceback.print_exception(exc_type, exc_value, exc_tb)
            print(e)
