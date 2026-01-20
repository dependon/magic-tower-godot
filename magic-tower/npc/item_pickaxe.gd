extends "res://npc/item.gd"

func interact(player):
	Global.play_sound("res://sounds/item.ogg")
	Global.has_pickaxe = true
	print("获得了杰克的锄头！")
	
	# 登记为已拾取
	Global.register_defeated(self)
	
	# 保存玩家状态
	Global.save_player_state(player)
	
	# 移除物品
	queue_free()
