class ActiveSkill(object):

    activeSkillReplaceMap = {
    '<img src="images/drops/Fire.png" width="25">':'火珠',
    '<img src="images/drops/Fire+.png" width="25">':'火+珠',
    '<img src="images/drops/Water.png" width="25">':'水珠',
    '<img src="images/drops/Water+.png" width="25">':'水+珠',
    '<img src="images/drops/Wood.png" width="25">':'木珠',
    '<img src="images/drops/Wood+.png" width="25">':'木珠',
    '<img src="images/drops/Light.png" width="25">':'光珠',
    '<img src="images/drops/Light+.png" width="25">':'光+珠',
    '<img src="images/drops/Dark.png" width="25">':'暗珠',
    '<img src="images/drops/Dark+.png" width="25">':'暗+珠',
    '<img src="images/drops/Poison.png" width="25">':'毒珠',
    '<img src="images/drops/Poison+.png" width="25">':'毒+珠',
    '<img src="images/drops/Dead.png" width="25">':'死珠',
    '<img src="images/drops/Dead+.png" width="25">':'死+珠',
    '<img src="images/drops/Heart.png" width="25">':'心珠',
    '<img src="images/drops/Heart+.png" width="25">':'心+珠',
    '<td colspan="5">':'',
    '<img src="images/change.gif">':'变成',
    '</td>':''
    }

    """docstring for activeSkill."""
    def __init__(self, item):
        # super(activeSkill, self).__init__()
        self.name = item["active_skill_name"]
        self.description = item["active_skill_description"]
        self.init_cd = item["active_skill_init_cd"]
        self.max_lvl_cd = item["active_skill_min_cd"]
        self.processActiveSkillDescription()

    def processActiveSkillDescription(self):
        for entry in self.activeSkillReplaceMap.items():
            # print("replacing: " + entry[0] + " to " + entry[1])
            self.description = self.description.replace(entry[0], entry[1])

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
