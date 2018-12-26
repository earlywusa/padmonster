Jobless Studio First Project~~

- padmonster_crawler
simple testing crawl tool for pad monsters

- DataStructure
define basic schema for the monsters

- app
server


CREATE TABLE IF NOT EXISTS "LeaderSkill" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`name`	TEXT,
	`description`	TEXT,
	`type`	TEXT
);
CREATE TABLE IF NOT EXISTS "AwokenSkillRelation" (
	`monster_id`	INTEGER,
	`skill_id`	INTEGER,
	`position`	INTEGER,
	`super_awoken`	INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS "Monster" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`MonsterId`	INTEGER NOT NULL UNIQUE,
	`Name`	TEXT,
	`MainAtt`	TEXT,
	`SubAtt`	TEXT,
	`LvMax`	INTEGER,
	`Hp`	INTEGER,
	`Atk`	INTEGER,
	`Rec`	INTEGER,
	`HpInc`	INTEGER,
	`AtkInc`	INTEGER,
	`RecInc`	INTEGER,
	`ActiveSkillId`	INTEGER,
	`LeaderSkillId`	INTEGER,
	`MonsterIconPath`	TEXT
);
CREATE TABLE IF NOT EXISTS "Type" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`Type`	TEXT,
	`TypeIconPath`	TEXT
);
CREATE TABLE IF NOT EXISTS "ActiveSkill" (
	`id`	INTEGER NOT NULL UNIQUE,
	`ActiveSkillId`	INTEGER UNIQUE,
	`ActiveSkillName`	TEXT,
	`ActiveSkillDescription`	TEXT,
	`MinCd`	INTEGER,
	`MaxCd`	INTEGER,
	`ActiveSkillType`	TEXT,
	PRIMARY KEY(`id`)
);
CREATE TABLE IF NOT EXISTS "TypeRelation" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`MonsterId`	INTEGER,
	`TypeId`	INTEGER
);
CREATE TABLE IF NOT EXISTS "AwokenSkill" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
	`AwokenSkillName`	TEXT,
	`AwokenSkillDescription`	TEXT,
	`AwokenSkillId`	INTEGER,
	`AwokenSkillIconPath`	TEXT
);
