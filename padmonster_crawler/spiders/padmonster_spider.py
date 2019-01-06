import scrapy
import sys
from scrapy.http import Request
from scrapy.selector import Selector
from urllib.parse import urljoin
from padmonster_crawler.items import PadmonsterItem
import re


class PadMonster(scrapy.spiders.Spider):
    """docstring for RecruitSpider."""
    name = "padmonster"
    # allowed_domains = ["douban.com"]
    allowed_domains = ["pad.skyozora.com"]
    # except 207, 4385
    start_id = 1
    end_id = 5050
    start_urls = ["http://pad.skyozora.com/pets/1"]
    count = 1
    def __init__(self, start_id=1, end_id=10):
        if int(end_id) < int(start_id):
            sys.exit("Invalid start_id: " + start_id + " end_id: " + end_id)
        self.start_id = int(start_id)
        self.end_id = int(end_id)
        start_url = "http://pad.skyozora.com/pets/"+ str(start_id)
        self.start_urls = [start_url]

    def parse(self, response):
        index = response.url.split("/")[-1]
        if type(index) == str:
            index = int(index)
        item = PadmonsterItem()
        item["monster_id"] = index
        selector = Selector(response)
        monsters_table = selector.xpath('//table[@border="0" and @cellpadding="10" and @cellspacing="1" and @width="720" and @align="center"]')
        # monsters = selector.xpath('//table[@border="0" and @cellpadding="5"]')
        # for i in range(len(monsters_table)):
        #     print("index: {}: ".format(i) )
        #     print(monsters_table[i].extract())
        if monsters_table != None and len(monsters_table) > 0:
            if monsters_table[0] != None:
                monster = monsters_table[0]
                item["icon_path_download"] = None
                icon_path_download = monster.xpath('tr[1]/td[1]/table[1]/tr[1]/td[1]/img/@src').extract()
                if len(icon_path_download) > 0:
                    item["icon_path_download"] = icon_path_download[0]

                name = monster.xpath('tr/td/table/tr/td/h2/text()').extract()
                if len(name) > 0:
                    # print(name)
                    name_str = name[0]
                    item['name'] = name_str
                rarity = monster.xpath('tr/td/table/tr/td/text()').extract()
                if len(rarity) > 0:
                    rarity_star = rarity[-1].count('★')
                    # print(rarity_star)
                    item['rarity'] = rarity_star
                # main_attr = monster.xpath('tr/td/a[1]/@title').extract()
                attrs = monster.xpath('tr/td[2]/a/@title').extract()
                if len(attrs) > 0:
                    # print(attrs)
                    item['main_attr'] = attrs[0].split(":")[1]
                if len(attrs) > 1:
                    item["sub_attr"] = attrs[1].split(":")[1]
                else:
                    item["sub_attr"] = None
                item["types"] = []
                types = monster.xpath('tr/td[3]/a/@title').extract()
                if len(types) > 0:
                    # print(types)
                    item['types'] = types
            if monsters_table[1] != None:
                monster = monsters_table[1]
                lv_max_status = monster.xpath('tr[2]/td[2]/table/tr/td/text()').extract()
                if len(lv_max_status) > 0:
                    # print("lvl max status: ")
                    # print(lv_max_status)
                    max_lvl = lv_max_status[0].split(".")[1]
                    hp_lv_max = lv_max_status[1].split(": ")[1]
                    atk_lv_max = lv_max_status[2].split(": ")[1]
                    rec_lv_max = lv_max_status[3].split(": ")[1]
                    item["lvl_max"] = max_lvl
                    item["hp_lv_max"] = hp_lv_max
                    item["atk_lv_max"] = atk_lv_max
                    item["rec_lv_max"] = rec_lv_max
                # lv_110_status = monster.xpath('tr[4]/td[2]/table/tr/td/text()').extract()
                lv_110_status = monster.xpath('tr[4]/td[2]/table/tr/td/text()').extract()
                print("lvl 110 max status: ")
                print(lv_110_status)
                item["hp_110"] = None
                item["atk_110"] = None
                item["rec_110"] = None
                if len(lv_110_status) > 0:
                    hp_110 = lv_110_status[1].split(": ")[1]
                    atk_110 = lv_110_status[2].split(": ")[1]
                    rec_110 = lv_110_status[3].split(": ")[1]
                    item["hp_110"] = hp_110
                    item["atk_110"] = atk_110
                    item["rec_110"] = rec_110
                else:
                    lv_110_status = monster.xpath('tr[td[contains(text(),"等級界限突破")]]')
                    if lv_110_status != None:
                        print(lv_110_status)
                        lv_110_status = lv_110_status.xpath('td[2]/table/tr[1]/td/text()').extract()
                        if len(lv_110_status) > 0:
                            hp_110 = lv_110_status[1].split(": ")[1]
                            atk_110 = lv_110_status[2].split(": ")[1]
                            rec_110 = lv_110_status[3].split(": ")[1]
                            item["hp_110"] = hp_110
                            item["atk_110"] = atk_110
                            item["rec_110"] = rec_110

            if monsters_table[3] != None:
                monster = monsters_table[3]
                active_skill_name = monster.xpath('tr[1]/td[1]/a/span/text()').extract()
                if len(active_skill_name) > 0:
                    print(active_skill_name)
                    item["active_skill_name"] = active_skill_name[0]
                else:
                    item["active_skill_name"] = None
                active_skill_init_cd = monster.xpath('tr[1]/td[3]/text()').extract()
                if len(active_skill_init_cd) > 0:
                    # print("active skill init cd:")
                    # print(active_skill_init_cd)
                    if active_skill_init_cd[0].strip() != '-':
                        active_skill_init_cd_int = int(active_skill_init_cd[0])
                        item["active_skill_init_cd"] = active_skill_init_cd_int
                    else:
                        item["active_skill_init_cd"] = None
                else:
                    item["active_skill_init_cd"] = None
                active_skill_min_cd = monster.xpath('tr[1]/td[5]/text()').extract()
                if len(active_skill_min_cd) > 0:
                    print(active_skill_min_cd[0].strip())
                    if active_skill_min_cd[0].strip() != '-':
                        active_skill_min_cd_int = int(active_skill_min_cd[0])
                        # print(active_skill_min_cd_int)
                        item["active_skill_min_cd"] = active_skill_min_cd_int
                    else:
                        item["active_skill_min_cd"] = None
                else:
                    item["active_skill_min_cd"] = None

                item["active_skill_description"] = None
                active_skill_description_raw = monster.xpath('tr[2]/td').extract()
                if len(active_skill_description_raw) > 0:
                    item["active_skill_description"] = "".join(active_skill_description_raw).strip()

                # active_skill_description = monster.xpath('tr[2]/td/text()').extract()
                # if len(active_skill_description) > 0:
                #     print(active_skill_description)
                #     active_skill_description_text = "".join(active_skill_description)
                #     item["active_skill_description"] = item["active_skill_description"] + active_skill_description_text.strip()
                #
                # active_skill_description_icon = monster.xpath('tr[2]/td/img/@src').extract()
                # if len(active_skill_description_icon) > 0:
                #     additional_description = ""
                #     for icon_path in active_skill_description_icon:
                #         element = icon_path.split("/")[-1].split(".")[0]
                #         additional_description = additional_description + " " + element
                #     item["active_skill_description"] = item["active_skill_description"] + additional_description


            if monsters_table[5] != None:
                monster = monsters_table[5]
                awoken_skills = monster.xpath('tr[1]/td[2]/a/@title').extract()
                if len(awoken_skills) > 0:
                    # print(awaken_skills)
                    skills = []
                    for skill in awoken_skills:
                        # s = 'asdf=5;iwantthis123jasd'
                        # result = re.search('asdf=5;(.*)123jasd', s)
                        # print result.group(1)
                        skill_str = re.search('【(.*)】', skill).group(1)
                        skills.append(skill_str)

                    item["awoken_skills"] = skills
                else:
                    item["awoken_skills"] = []

                super_awoken_skills = monster.xpath('tr[2]/td[2]/a/@title').extract()
                # print (super_awoken_skills)
                if len(super_awoken_skills) > 0:
                    print(super_awoken_skills)
                    skills = []
                    for skill in super_awoken_skills:
                        # s = 'asdf=5;iwantthis123jasd'
                        # result = re.search('asdf=5;(.*)123jasd', s)
                        # print result.group(1)
                        skill_str = re.search('【(.*)】', skill).group(1)
                        skills.append(skill_str)

                    item["super_awoken_skills"] = skills
                else:
                    item["super_awoken_skills"] = []
                    print("cannot find any super awokenskills")

            if monsters_table[6] != None:
                monster = monsters_table[6]
                leader_skill_name = monster.xpath('tr[1]/td/a/span/text()').extract()
                if len(leader_skill_name) > 0:
                    # print(leader_skill_name[0])
                    leader_skill_name_str = leader_skill_name[0].strip()
                    if leader_skill_name_str != None:
                        item["leader_skill_name"] = leader_skill_name[0]
                else:
                    item["leader_skill_name"] = None
                leader_skill_type = monster.xpath('tr[2]/td/img/@src').extract()
                if len(leader_skill_type) > 0:
                    # print(leader_skill_type[0])
                    # type = re.search('/(.*).', leader_skill_type[0]).group(1)
                    ls_type = leader_skill_type[0].split("/")[-1].split(".")[0]
                    item["leader_skill_type"] = ls_type
                else:
                    item["leader_skill_type"] = None
                leader_skill_description = monster.xpath('tr[2]/td/text()').extract()
                item["leader_skill_description"] = None
                if len(leader_skill_description) > 0:
                    print(leader_skill_description)
                    leader_skill_description_str = "".join(leader_skill_description).strip()
                    if leader_skill_description_str != "":
                        item["leader_skill_description"] = leader_skill_description_str

            #icon_path_download
            # icon_path_download = selector.xpath('link[@rel="image_src"]/@href').extract()
            # if len(icon_path_download) > 0:
            #     #print(icon_path_download)
            #     item["icon_path_download"] = icon_path_download[0]
            # else:
            #     item["icon_path_download"] = ""



        print("^^^^^^^^^")
        if item != None and "name" in item and item["name"] != "":
            yield item
        print("---------------")

        count = index+1
        # count = 4284
        #3270 hadis , 110 available
        #3274 little white dog, 110 unavailable

        #debug
        # nextLink = "http://pad.skyozora.com/pets/3270"
        # print(nextLink)
        # yield Request(urljoin(response.url, nextLink), callback = self.parse)


        if count <= self.end_id:
            nextLink = "http://pad.skyozora.com/pets/" + str(count)
            print(nextLink)
            yield Request(urljoin(response.url, nextLink), callback = self.parse)
