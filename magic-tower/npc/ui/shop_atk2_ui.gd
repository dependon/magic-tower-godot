extends CanvasLayer

signal shop_closed
signal trade_completed

@onready var options = [
	$Control/Panel/VBoxContainer/Yes,
	$Control/Panel/VBoxContainer/No
]

var current_index = 0
var player = null
var npc_ref = null # 用于在交易完成后让 NPC 消失

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
		0: # 我要
			if player.experience >= 500:
				player.experience -= 500
				player.atk += 120
				Global.save_player_state(player)
				print("交易成功：500经验换取120攻击力")
				emit_signal("trade_completed")
				close_shop()
			else:
				print("经验不足，无法交换！")
		1: # 谢谢，不用
			close_shop()

func close_shop():
	if player:
		player.is_talking = false
	emit_signal("shop_closed")
	queue_free()
