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

# 回收价格配置
var yellow_price = 7
var blue_price = 35
var red_price = 70

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
		0: # 黄钥匙
			sell_key("yellow_keys", yellow_price)
		1: # 蓝钥匙
			sell_key("blue_keys", blue_price)
		2: # 红钥匙
			sell_key("red_keys", red_price)
		3: # Exit
			close_shop()

func sell_key(key_type: String, price: int):
	var key_count = 0
	if key_type in player:
		key_count = player.get(key_type)
	
	if key_count > 0:
		# 扣除钥匙
		player.set(key_type, key_count - 1)
		# 增加金币
		player.gold += price
		
		# 更新全局状态
		Global.save_player_state(player)
		print("卖出成功: ", key_type, " 获得金币: ", price)
	else:
		print("钥匙不足，无法出售！")

func close_shop():
	if player:
		player.is_talking = false
	emit_signal("shop_closed")
	queue_free()
