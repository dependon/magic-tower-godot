extends Node

var target_portal_id: String = ""

# 玩家持久化属性
var hp: int = 1000
var atk: int = 10
var def: int = 10
var gold: int = 0
var experience: int = 0

# 保存玩家当前状态到全局
func save_player_state(player):
	hp = player.hp
	atk = player.atk
	def = player.def
	gold = player.gold
	experience = player.experience

# 将全局状态应用到玩家
func load_player_state(player):
	player.hp = hp
	player.atk = atk
	player.def = def
	player.gold = gold
	player.experience = experience
