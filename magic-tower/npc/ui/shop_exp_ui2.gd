extends CanvasLayer

signal shop_closed

@onready var options = [
	$Control/Panel/VBoxContainer/Level,
	$Control/Panel/VBoxContainer/ATK,
	$Control/Panel/VBoxContainer/DEF,
	$Control/Panel/VBoxContainer/Exit
]

var current_index = 0
var player = null

func _ready():
	update_selection()

func _input(event):
	if event.is_action_pressed("ui_up"):
		current_index = posmod(current_index - 1, options.size())
		update_selection()
	elif event.is_action_pressed("ui_down"):
		current_index = posmod(current_index + 1, options.size())
		update_selection()
	elif event.is_action_pressed("ui_accept"):
		handle_selection()

func update_selection():
	for i in range(options.size()):
		var label = options[i]
		if i == current_index:
			label.add_theme_color_override("font_color", Color.YELLOW)
			label.get_node("SelectionRect").show()
		else:
			label.add_theme_color_override("font_color", Color.WHITE)
			label.get_node("SelectionRect").hide()

func handle_selection():
	match current_index:
		0: # 等级+3 (270经验)
			buy_stat("level", 3, 270)
		1: # 攻击+17 (95经验)
			buy_stat("atk", 17, 95)
		2: # 防御+17 (95经验)
			buy_stat("def", 17, 95)
		3: # 离开
			close_shop()

func buy_stat(stat_name: String, amount: int, cost: int):
	if player.experience >= cost:
		player.experience -= cost
		match stat_name:
			"level": 
				player.level += amount
				# 按照通常魔塔逻辑，升级会增加生命、攻击和防御
				player.hp += 3000 # 3级给3000
				player.atk += 21 # 3级给21
				player.def += 21 # 3级给21
			"atk": player.atk += amount
			"def": player.def += amount
		
		# 更新全局状态
		Global.save_player_state(player)
		print("经验购买成功: ", stat_name, "+", amount)
	else:
		print("经验不足！")

func close_shop():
	if player:
		player.is_talking = false
	emit_signal("shop_closed")
	queue_free()
