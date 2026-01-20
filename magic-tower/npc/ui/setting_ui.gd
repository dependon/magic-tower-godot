extends CanvasLayer

@onready var sfx_slider = $Control/Panel/VBoxContainer/SFXContainer/SFXSlider
@onready var bgm_slider = $Control/Panel/VBoxContainer/BGMContainer/BGMSlider
@onready var restart_btn = $Control/Panel/VBoxContainer/RestartButton
@onready var exit_btn = $Control/Panel/VBoxContainer/ExitButton
@onready var close_btn = $Control/Panel/CloseButton

func _ready():
	# 初始化滑块值
	# 音效控制 Global.sfx_volume_db
	sfx_slider.value = db_to_linear(Global.sfx_volume_db)
	
	# BGM 控制 Global.bgm_player 的音量
	if Global.bgm_player:
		bgm_slider.value = db_to_linear(Global.bgm_player.volume_db)
	
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	restart_btn.pressed.connect(_on_restart_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	close_btn.pressed.connect(queue_free)

func _on_sfx_volume_changed(value):
	Global.sfx_volume_db = linear_to_db(value)

func _on_bgm_volume_changed(value):
	if Global.bgm_player:
		Global.bgm_player.volume_db = linear_to_db(value)

func _on_restart_pressed():
	Global.reset_game()
	get_tree().change_scene_to_file("res://main_menu.tscn")
	queue_free()

func _on_exit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
