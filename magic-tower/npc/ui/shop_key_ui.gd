extends CanvasLayer

signal shop_closed

@onready var options = [
	$Control/Panel/VBoxContainer/YellowKey,
	$Control/Panel/VBoxContainer/BlueKey,
	$Control/Panel/VBoxContainer/RedKey,
	$Control/Panel/VBoxContainer/Exit
]

var current_index = 0
var player = null

func _ready():
	update_selection()
	
	# 设置 Label 接收鼠标事件
	for i in range(options.size()):
		var label = options[i]
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.gui_input.connect(_on_label_gui_input.bind(i))
		label.mouse_entered.connect(_on_label_mouse_entered.bind(i))

func _on_label_gui_input(event, index):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_index = index
		handle_selection()

func _on_label_mouse_entered(index):
	current_index = index
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
	elif event.is_action_pressed("ui_cancel"):
		close_shop()

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
		0: # Yellow Key (10 Gold)
			buy_key("yellow", 10)
		1: # Blue Key (50 Gold)
			buy_key("blue", 50)
		2: # Red Key (100 Gold)
			buy_key("red", 100)
		3: # Exit
			close_shop()

func buy_key(key_type: String, cost: int):
	if player.gold >= cost:
		player.gold -= cost
		match key_type:
			"yellow": player.key_yellow += 1
			"blue": player.key_blue += 1
			"red": player.key_red += 1
		
		# 更新全局状态
		Global.save_player_state(player)
		print("钥匙购买成功: ", key_type, " 钥匙")
	else:
		print("金币不足！")

func close_shop():
	player.is_talking = false
	emit_signal("shop_closed")
	queue_free()
