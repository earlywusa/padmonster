from padmonster_crawler.models.awoken_skills import AwokenSkills
from padmonster_crawler.models.leader_skill import LeaderSkill
from padmonster_crawler.models.active_skill import ActiveSkill

class Monster(object):
    """docstring for Monster."""
    id = None
    name = None
    main_attr = None
    sub_attr = None
    lvl_max = 99
    hp_lv_max = None
    atk_lv_max = None
    rec_lv_max = None
    hp_110 = None
    atk_110 = None
    rec_110 = None

    monsterTable = "Monster"

    def __init__(self, item):
        super(Monster, self).__init__()
        self.id = item['monster_id']
        self.name = item['name']
        self.main_attr = item['main_attr']
        self.sub_attr = item['sub_attr']
        self.hp_lv_max = item['hp_lv_max']
        self.atk_lv_max = item['atk_lv_max']
        self.rec_lv_max = item['rec_lv_max']
        self.hp_110 = item['hp_110']
        self.atk_110 = item['atk_110']
        self.rec_110 = item['rec_110']
        self.icon_path_download = item['icon_path_download']
        self.awokenSkills = AwokenSkills(item)
        self.leaderSkill = LeaderSkill(item)
        self.activeSkill = ActiveSkill(item)
        self.lvl_max = item["lvl_max"]
        self.types = item["types"]

    def insertAwokenSkill(self, handler):
        if self.awokenSkills != None:
            return self.awokenSkills.insertScript(self, awokenSkillDict)

    def isExist(self, handler):
        #move to monster class later
        sql = "select * from Monster where MonsterId = " + str(self.id)
        # print("query sql: " + sql)
        rows = handler.query(sql)
        if len(rows) > 0:
            return True
        # print(rows)
        return False

    def insertTypes(self, handler):
        sql = "select MonsterId from TypeRelation where MonsterId = " + str(self.id) + ";"
        rows = handler.query(sql)
        if len(rows) == 0:
            for type in self.types:
                typeId = handler.monsterTypeDic[type]
                sql = "insert into TypeRelation ( \
                MonsterId, \
                TypeId )\
                values (?,?);"
                obj = (self.id, typeId)
                # print("insert type: " + sql)
                id = handler.insert(sql, obj)

    def insert(self, handler):
        self.insertTypes(handler)
        self.awokenSkills.insertRelation(self, handler)

        if self.isExist(handler):
            print("found monster, do nothing")
            return None
        leaderSkillId = self.leaderSkill.insertSkill(self, handler)
        print("leader skill id: {}".format(leaderSkillId))
        activeSkillId = self.activeSkill.insertSkill(self, handler)
        print("active skill id: {}".format(activeSkillId))
        sql = "insert into " + self.monsterTable + " \
        (MonsterId, \
        Name, \
        MainAtt, \
        SubAtt, \
        LvMax, \
        Hp, \
        Atk, \
        Rec, \
        Hp110, \
        Atk110, \
        Rec110, \
        ActiveSkillId, \
        LeaderSkillId, \
        MonsterIconPathDownload) \
        values (?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
        obj = (self.id,
        self.name,
        self.main_attr,
        self.sub_attr,
        self.lvl_max,
        self.hp_lv_max,
        self.atk_lv_max,
        self.rec_lv_max,
        self.hp_110,
        self.atk_110,
        self.rec_110,
        activeSkillId,
        leaderSkillId,
        self.icon_path_download)
        monster_row_id = handler.insert(sql, obj)


        return monster_row_id

    def differ(monster1, monster2):
        columns  = []
        if(monster1.name != monster2.name):
            columns.append("name")
        if(monster1.main_attr != monster2.main_attr):
            columns.append("main_attr")
        if(monster1.sub_attr != monster2.sub_attr):
            columns.append("sub_attr")
        if(monster1.hp_lv_max != monster2.hp_lv_max):
            columns.append("hp_lv_max")
        if(monster1.atk_lv_max != monster2.atk_lv_max):
            columns.append("atk_lv_max")
        if(monster1.rec_lv_max != monster2.rec_lv_max):
            columns.append("rec_lv_max")
        if(monster1.hp_110 != monster2.hp_110):
            columns.append("hp_110")
        if(monster1.atk_110 != monster2.atk_110):
            columns.append("atk_110")
        if(monster1.rec_110 != monster2.rec_110):
            columns.append("rec_110")
