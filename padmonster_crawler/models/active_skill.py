class ActiveSkill(object):
    """docstring for activeSkill."""
    def __init__(self, item):
        # super(activeSkill, self).__init__()
        self.name = item["active_skill_name"]
        self.description = item["active_skill_description"]
        self.init_cd = item["active_skill_init_cd"]
        self.max_lvl_cd = item["active_skill_min_cd"]

    def insertSkill(self, monster, handler):
        id = None
        print("active skill name:")
        print(self.name)
        if self.name != "":
            if self.name not in handler.activeSkillDic:
                sql = "insert into ActiveSkill ( \
                ActiveSkillName, \
                ActiveSkillDescription, \
                MinCd, \
                MaxCd \
                ) \
                values (?,?,?,?)"
                obj = (self.name, self.description, self.max_lvl_cd, self.init_cd)
                id =  handler.insert(sql,obj)
                handler.activeSkillDic[self.name] = id
                return id
            else:
                id = handler.activeSkillDic.get(self.name)
        return id
