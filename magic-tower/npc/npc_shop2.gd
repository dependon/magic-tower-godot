extends Area2D

@onready var shop_exp_ui_scene = preload("res://npc/ui/shop_exp_ui.tscn")

func _ready():
	pass

func interact(player):
	if player.is_talking:
		return
		
	# 禁用玩家移动
	player.is_talking = true
	
	# 实例化并显示经验商店 UI
	var shop_instance = shop_exp_ui_scene.instantiate()
	shop_instance.player = player
	get_tree().root.add_child(shop_instance)
	
	print("打开经验商店")
