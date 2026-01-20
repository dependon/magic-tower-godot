extends CanvasLayer

@onready var floor_label = $Control/VBoxContainer/HBoxContainer/floor
@onready var lv_label = $Control/VBoxContainer/HBoxContainer2/lv
@onready var hp_label = $Control/VBoxContainer/HBoxContainer3/hp
@onready var atk_label = $Control/VBoxContainer/HBoxContainer4/atk
@onready var def_label = $Control/VBoxContainer/HBoxContainer5/def
@onready var gold_label = $Control/VBoxContainer/HBoxContainer6/gold
@onready var exp_label = $Control/VBoxContainer/HBoxContainer7/experience
@onready var key_y_label = $Control/VBoxContainer/HBoxContainer8/key_yellow
@onready var key_b_label = $Control/VBoxContainer/HBoxContainer8/key_blue
@onready var key_r_label = $Control/VBoxContainer/HBoxContainer8/key_red

func _ready():
	# 确保 HUD 在最底层，或者通过 CanvasLayer 的 layer 属性控制
	layer = 100 
	
func _process(_delta):
	# 动态调整当前场景的位置，使其不被 HUD 遮挡
	var current_scene = get_tree().current_scene
	
	# 如果是主菜单，隐藏 HUD 并不调整位置
	if current_scene and current_scene.name == "MainMenu":
		visible = false
		return
	else:
		visible = true

	if current_scene and current_scene != self and current_scene.name != "HUD":
		# 假设 HUD 宽度为 160 像素 (5个网格)
		current_scene.position.x = 160
	
	# 优先从场景中的玩家获取实时数据，如果没有则从 Global 获取
	var player = get_tree().get_first_node_in_group("player")
	if player:
		hp_label.text = str(player.hp)
		atk_label.text = str(player.atk)
		def_label.text = str(player.def)
		gold_label.text = str(player.gold)
		exp_label.text = str(player.experience)
		lv_label.text = str(player.level)
		key_y_label.text = str(player.key_yellow).pad_zeros(2)
		key_b_label.text = str(player.key_blue).pad_zeros(2)
		key_r_label.text = str(player.key_red).pad_zeros(2)
	else:
		hp_label.text = str(Global.hp)
		atk_label.text = str(Global.atk)
		def_label.text = str(Global.def)
		gold_label.text = str(Global.gold)
		exp_label.text = str(Global.experience)
		lv_label.text = str(Global.level)
		key_y_label.text = str(Global.key_yellow).pad_zeros(2)
		key_b_label.text = str(Global.key_blue).pad_zeros(2)
		key_r_label.text = str(Global.key_red).pad_zeros(2)
	
	floor_label.text = Global.floor_name


func _on_btn_fly_pressed() -> void:
	# 检查是否已经打开了跳跃界面
	for child in get_children():
		if child.name == "FloorJumpUI":
			return
			
	var floor_jump_scene = load("res://npc/ui/floor_jump_ui.tscn")
	var floor_jump_ui = floor_jump_scene.instantiate()
	add_child(floor_jump_ui)

func _on_btn_save_pressed() -> void:
	if not Global.can_save():
		_show_message("当前楼层魔力混乱，无法存档！")
		return
	_open_save_load_ui(0) # 0 for SAVE

func _show_message(text: String):
	var dialogue_ui_scene = load("res://npc/ui/dialogue_ui.tscn")
	var ui = dialogue_ui_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_talking = true
		ui.player_ref = player
	
	ui.dialogue_queue = [
		{"name": "系统", "icon": null, "text": text}
	]
	get_tree().root.add_child(ui)

func _on_btn_load_pressed() -> void:
	_open_save_load_ui(1) # 1 for LOAD

func _open_save_load_ui(mode: int):
	for child in get_children():
		if child.name == "SaveLoadUI":
			return
			
	var scene = load("res://npc/ui/save_load_ui.tscn")
	var ui = scene.instantiate()
	ui.set_mode(mode)
	add_child(ui)


func _on_btn_book_pressed() -> void:
	for child in get_children():
		if child.name == "MonsterBookUI":
			return
			
	var scene = load("res://npc/ui/monster_book_ui.tscn")
	var ui = scene.instantiate()
	add_child(ui)


func _on_btn_shop_pressed() -> void:
	for child in get_children():
		if child.name == "QuickShopUI":
			return
			
	var scene = load("res://npc/ui/quick_shop_ui.tscn")
	var ui = scene.instantiate()
	add_child(ui)


func _on_btn_setting_pressed() -> void:
	for child in get_children():
		if child.name == "SettingUI":
			return
			
	var scene = load("res://npc/ui/setting_ui.tscn")
	var ui = scene.instantiate()
	add_child(ui)
