class LeaderSkill(object):
    """docstring for leaderSkill."""
    def __init__(self, item):
        self.name = item["leader_skill_name"]
        self.type = item["leader_skill_type"]
        self.description = item["leader_skill_description"]
        # self.processLeaderSkillDescription()

    def processLeaderSkillDescription(self):
        while self.description.find('<') >= 0 and self.description.find('>') >= 0:
            start = self.description.find('<')
            end = self.description.find('>')
            if start < end:
                self.description = self.description[0:start] + self.description[end+1: len(self.description)]

    def getSkillId(self, monster, handler):
        id = None
        if self.name != "" and self.name in handler.leaderSkillDic:
            id = handler.leaderSkillDic.get(self.name)
        else:
            sql = "select LeaderSkillId from LeaderSkill where LeaderSkillName = '" + self.name +"';"
            rows = handler.query(sql)
            id = rows[0]
        return id

    def updateSkill(self, monster, handler, id):
        sql = "update LeaderSkill set LeaderSkillDescription = ? where LeaderSkillId = ?;"
        handler.update(sql, (self.description, id))


    def insertSkill(self, monster, handler):
        id = None
        if self.name != "" and self.name is not None:
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
            else:
                id = handler.leaderSkillDic.get(self.name)
                self.updateSkill(monster, handler, id)
        return id
