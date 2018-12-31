class AwokenSkills(object):
    awokenSkillTable = "AwokenSkill"
    awokenSkillRelationTable = "AwokenSkillRelation"
    def __init__(self, item):
        # super(awokenSkills, self).__init__()
        self.awokenSkills = item['awoken_skills']
        self.superAwokenSkills = item['super_awoken_skills']

    def isExist(self, monster, handler):
        sql = "select * from AwokenSkillRelation where MonsterId = " + str(monster.id) + ";"
        if len(handler.query(sql)) > 0:
            return True
        return False

    def insertRelation(self, monster, handler):
        if self.isExist(monster, handler):
            return None
        position = 1
        for skill in self.awokenSkills:
            awokenSkillId = handler.awokenSkillDic[skill]
            sql = "insert into " + self.awokenSkillRelationTable + " (MonsterId, AwokenSkillId, Position) \
            values (?,?,?);"
            obj = (monster.id, awokenSkillId, position)
            handler.insert(sql, obj)
            position += 1
        for skill in self.superAwokenSkills:
            awokenSkillId = handler.awokenSkillDic[skill]
            sql = "insert into " + self.awokenSkillRelationTable + " (MonsterId, AwokenSkillId, Position, SuperAwoken) \
            values (?,?,?,?);"
            obj = (monster.id, awokenSkillId, position, 1)
            handler.insert(sql, obj)
            position += 1
