extends Area2D

@onready var shop_ui_scene = preload("res://npc/ui/shop_ui.tscn")

func _ready():
	# 商店 NPC 通常是常驻的，但如果以后需要消失逻辑可以参考 Global.is_defeated
	pass

func interact(player):
	if player.is_talking:
		return
		
	# 禁用玩家移动
	player.is_talking = true
	
	# 实例化并显示商店 UI
	var shop_instance = shop_ui_scene.instantiate()
	shop_instance.player = player
	get_tree().root.add_child(shop_instance)
	
	print("打开商店")
