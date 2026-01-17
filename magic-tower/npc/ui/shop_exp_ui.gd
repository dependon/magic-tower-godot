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
		0: # Level +1 (100 Exp)
			buy_stat("level", 1, 100)
		1: # ATK +5 (30 Exp)
			buy_stat("atk", 5, 30)
		2: # DEF +5 (30 Exp)
			buy_stat("def", 5, 30)
		3: # Exit
			close_shop()

func buy_stat(stat_name: String, amount: int, cost: int):
	if player.experience >= cost:
		player.experience -= cost
		match stat_name:
			"level": 
				player.level += amount
				# 通常魔塔中升级也会增加其他属性，这里仅按照用户要求增加等级
				player.hp += 1000 # 习惯性给点生命奖励，可根据需要删除
				player.atk += 7
				player.def += 7
			"atk": player.atk += amount
			"def": player.def += amount
		
		# 更新全局状态
		Global.save_player_state(player)
		print("经验购买成功: ", stat_name, "+", amount)
	else:
		print("经验不足！")

func close_shop():
	player.is_talking = false
	emit_signal("shop_closed")
	queue_free()
