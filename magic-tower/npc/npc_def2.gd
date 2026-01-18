extends Area2D

@onready var shop_ui_scene = preload("res://npc/ui/shop_def2_ui.tscn")

func _ready():
	# 检查是否已经完成了交易
	if Global.is_defeated(self):
		queue_free()

func interact(player):
	if player.is_talking:
		return
		
	# 禁用玩家移动
	player.is_talking = true
	
	# 实例化并显示商店 UI
	var shop_instance = shop_ui_scene.instantiate()
	shop_instance.player = player
	shop_instance.npc_ref = self
	get_tree().root.add_child(shop_instance)
	
	# 连接交易完成信号
	shop_instance.trade_completed.connect(_on_trade_completed)
	
	print("与神秘老人对话：500经验换120防御力")

func _on_trade_completed():
	# 登记为已拾取/消失
	Global.register_defeated(self)
	# 渐渐消失效果
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(queue_free)
