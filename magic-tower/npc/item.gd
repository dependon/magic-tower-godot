extends Area2D

@export_group("Stats Bonus")
@export var hp_bonus: int = 0
@export var atk_bonus: int = 0
@export var def_bonus: int = 0
@export var level_bonus: int = 0
@export var gold_bonus: int = 0

@export_group("Keys Bonus")
@export var key_yellow: int = 0
@export var key_blue: int = 0
@export var key_red: int = 0


func _ready():
	# 检查该物品是否已经被拾取
	if Global.is_defeated(self):
		queue_free()
		return
	

func interact(player):
	Global.play_sound("res://sounds/item.ogg")
	# 应用属性加成
	player.hp += hp_bonus
	player.atk += atk_bonus
	player.def += def_bonus
	player.level += level_bonus
	player.gold += gold_bonus
	# 应用钥匙加成
	player.key_yellow += key_yellow
	player.key_blue += key_blue
	player.key_red += key_red
	
	
	# 打印提示信息（可选，后续可以增加飘字效果）
	var msg = "获得: "
	if gold_bonus > 0: msg += "金币+%d " % gold_bonus
	if level_bonus > 0: msg += "等级+%d " % level_bonus
	if hp_bonus > 0: msg += "生命+%d " % hp_bonus
	if atk_bonus > 0: msg += "攻击+%d " % atk_bonus
	if def_bonus > 0: msg += "防御+%d " % def_bonus
	if key_yellow > 0: msg += "黄钥匙+%d " % key_yellow
	if key_blue > 0: msg += "蓝钥匙+%d " % key_blue
	if key_red > 0: msg += "红钥匙+%d " % key_red
	print(msg)
	
	# 登记为已拾取
	Global.register_defeated(self)
	
	# 保存玩家状态以供持久化
	Global.save_player_state(player)
	
	# 移除物品
	queue_free()
