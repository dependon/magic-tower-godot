extends Control

@onready var btn_start = $VBoxContainer/BtnStart
@onready var btn_load = $VBoxContainer/BtnLoad
@onready var btn_about = $VBoxContainer/BtnAbout
@onready var btn_exit = $VBoxContainer/BtnExit

func _ready():
	# 确保主菜单居中显示
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 连接信号
	btn_start.pressed.connect(_on_btn_start_pressed)
	btn_load.pressed.connect(_on_btn_load_pressed)
	btn_about.pressed.connect(_on_btn_about_pressed)
	btn_exit.pressed.connect(_on_btn_exit_pressed)

func _on_btn_start_pressed():
	Global.new_game()

func _on_btn_load_pressed():
	var save_load_scene = load("res://npc/ui/save_load_ui.tscn")
	var save_load_ui = save_load_scene.instantiate()
	# 设置为加载模式 (Mode.LOAD = 1)
	save_load_ui.set_mode(1) 
	add_child(save_load_ui)

func _on_btn_about_pressed():
	var about_scene = load("res://npc/ui/about_ui.tscn")
	var about_ui = about_scene.instantiate()
	add_child(about_ui)

func _on_btn_exit_pressed():
	get_tree().quit()
