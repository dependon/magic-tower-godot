extends CanvasLayer

signal shop_closed

@onready var options = [
	$Control/Panel/VBoxContainer/HP,
	$Control/Panel/VBoxContainer/ATK,
	$Control/Panel/VBoxContainer/DEF,
	$Control/Panel/VBoxContainer/Exit
]

var current_index = 0
var player = null
var cost = 25

func _ready():
	update_selection()
	# 播放出现动画（可选）

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
			# 这里可以添加黄色边框效果
			label.get_node("SelectionRect").show()
		else:
			label.add_theme_color_override("font_color", Color.WHITE)
			label.get_node("SelectionRect").hide()

func handle_selection():
	match current_index:
		0: # HP +800
			buy_stat("hp", 800)
		1: # ATK +4
			buy_stat("atk", 4)
		2: # DEF +4
			buy_stat("def", 4)
		3: # Exit
			close_shop()

func buy_stat(stat_name: String, amount: int):
	if player.gold >= cost:
		player.gold -= cost
		match stat_name:
			"hp": player.hp += amount
			"atk": player.atk += amount
			"def": player.def += amount
		
		# 更新全局状态
		Global.save_player_state(player)
		print("购买成功: ", stat_name, "+", amount)
	else:
		print("金币不足！")

func close_shop():
	player.is_talking = false # 恢复玩家移动
	emit_signal("shop_closed")
	queue_free()
