extends Node

var target_portal_id: String = ""

# 玩家持久化属性
var hp: int = 1000
var atk: int = 10
var def: int = 10
var gold: int = 0
var experience: int = 0
var floor_name: String = "0"
var level: int = 1
var key_yellow: int = 0
var key_blue: int = 0
var key_red: int = 0

# 保存玩家当前状态到全局
func save_player_state(player):
	hp = player.hp
	atk = player.atk
	def = player.def
	gold = player.gold
	experience = player.experience
	if "level" in player: level = player.level
	if "key_yellow" in player: key_yellow = player.key_yellow
	if "key_blue" in player: key_blue = player.key_blue
	if "key_red" in player: key_red = player.key_red

# 将全局状态应用到玩家
func load_player_state(player):
	player.hp = hp
	player.atk = atk
	player.def = def
	player.gold = gold
	player.experience = experience
	if "level" in player: player.level = level
	if "key_yellow" in player: player.key_yellow = key_yellow
	if "key_blue" in player: player.key_blue = key_blue
	if "key_red" in player: player.key_red = key_red
