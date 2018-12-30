class LeaderSkill(object):
    """docstring for leaderSkill."""
    def __init__(self, item):
        self.name = item["leader_skill_name"]
        self.type = item["leader_skill_type"]
        self.description = item["leader_skill_description"]

    def insertSkill(self, monster, handler):
        id = None
        if self.name != "":
            if self.name not in handler.leaderSkillDic:
                sql = "insert into LeaderSkill ( \
                LeaderSkillName, \
                LeaderSkillDescription \
                ) \
                values (?,?)"
                obj = (self.name, self.description)
                id = handler.insert(sql,obj)
                handler.leaderSkillDic[self.name] = id
                if self.type != None and self.type != "":
                    sql = "insert into LeaderSkillType ( \
                    LeaderSkillId, \
                    LeaderSkillType ) \
                    values (?,?)"
                    obj = (id, self.type)
                    handler.insert(sql, obj)

                return id
            else:
                id = handler.leaderSkillDic.get(self.name)
        return id
