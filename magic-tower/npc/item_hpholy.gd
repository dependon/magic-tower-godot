extends "res://npc/item.gd"

func interact(player):
	Global.play_sound("res://sounds/item.ogg")
	# 圣水逻辑：生命值翻倍
	var old_hp = player.hp
	player.hp *= 2
	
	print("获得圣水：生命值从 %d 变为 %d" % [old_hp, player.hp])
	
	# 登记为已拾取
	Global.register_defeated(self)
	
	# 保存玩家状态
	Global.save_player_state(player)
	
	# 移除物品
	queue_free()
