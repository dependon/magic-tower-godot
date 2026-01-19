extends Area2D

@onready var dialogue_ui_scene = preload("res://npc/ui/dialogue_ui.tscn")
@onready var hero_tex = preload("res://images/hero.png")
@onready var npc_tex = preload("res://images/npcs.png")

var warrior_icon = AtlasTexture.new()
var fairy_icon = AtlasTexture.new()

func _ready():
	# 初始化头像
	warrior_icon.atlas = hero_tex
	warrior_icon.region = Rect2(0, 0, 32, 32)
	
	fairy_icon.atlas = npc_tex
	fairy_icon.region = Rect2(0, 96, 32, 32)
	
	# 检查任务阶段，如果已完成则消失
	if Global.fairy2_quest_stage >= 2 or Global.is_defeated(self):
		queue_free()
		return

func interact(player):
	if Global.has_staff_fire and Global.has_staff_ice:
		complete_staff_quest(player)
	else:
		start_staff_quest(player)

func start_staff_quest(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "仙子", "icon": fairy_icon, "text": "请找寻两个魔法杖，当同时拥有冰火之力的时候，我会帮你封印魔神的大部分力量"}
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func():
		Global.fairy2_quest_stage = 1
	)

func complete_staff_quest(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "仙子", "icon": fairy_icon, "text": "你已经拥有了冰火之杖，我现在就为你封印魔神！"},
		{"name": "仙子", "icon": fairy_icon, "text": "去吧，勇士，消灭虚弱的魔神！"}
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func():
		Global.is_boss_sealed = true
		Global.fairy2_quest_stage = 2
		Global.register_defeated(self)
		queue_free()
	)
