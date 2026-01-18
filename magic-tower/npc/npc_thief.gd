extends Area2D

@onready var dialogue_ui_scene = preload("res://npc/ui/dialogue_ui.tscn")
@onready var hero_tex = preload("res://images/hero.png")
@onready var npc_tex = preload("res://images/npcs.png")

var warrior_icon = AtlasTexture.new()
var jack_icon = AtlasTexture.new()

func _ready():
	# 如果杰克已经去开启通路了，则消失
	if Global.jack_quest_stage >= 2 or Global.is_defeated(self):
		queue_free()
		return

	warrior_icon.atlas = hero_tex
	warrior_icon.region = Rect2(0, 0, 32, 32)
	
	jack_icon.atlas = npc_tex
	jack_icon.region = Rect2(0, 64, 32, 32)

func interact(player):
	if player.is_talking:
		return
		
	match Global.jack_quest_stage:
		0:
			start_stage_0(player)
		1:
			if Global.has_pickaxe:
				start_stage_1_complete(player)
			else:
				start_stage_1_waiting(player)
		2:
			start_stage_2(player)

func start_stage_0(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "勇士", "icon": warrior_icon, "text": "你得救了！", "name_color": Color.YELLOW},
		{"name": "杰克", "icon": jack_icon, "text": "啊谢谢你！ 我叫杰克，是一名寻宝猎人，有一天无意中闯 入了这座塔，结果被这里的魔物们发现给关在 了这里。"},
		{"name": "杰克", "icon": jack_icon, "text": "另外，我有一把锄头遗失在了这座塔里，如果 你能帮我找到，我就可以为你打开18楼的通 路"},
		{"name": "勇士", "icon": warrior_icon, "text": "好的，我会尽力去寻找", "name_color": Color.YELLOW}
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func(): 
		Global.jack_quest_stage = 1
		_register_door_spec_defeated()
	)

func _register_door_spec_defeated():
	# 手动构造 door_spec 的 ID 并注册
	# 场景: map2, 节点路径: door_spec
	var door_id = "map2:door_spec"
	Global.defeated_objects[door_id] = true
	print("map2 的 door_spec 已标记为消失")

func start_stage_1_waiting(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "杰克", "icon": jack_icon, "text": "你找到锄头了吗？"},
		{"name": "勇士", "icon": warrior_icon, "text": "还在寻找，我再去找找", "name_color": Color.YELLOW}
	]
	get_tree().root.add_child(ui)

func start_stage_1_complete(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "勇士", "icon": warrior_icon, "text": "我找到了你的锄头！", "name_color": Color.YELLOW},
		{"name": "杰克", "icon": jack_icon, "text": "太好了！这就是我的锄头。我现在就去为你打开18楼的通路"},
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func(): 
		Global.jack_quest_stage = 2
		Global.has_pickaxe = false # 消耗掉锄头
		Global.register_defeated(self)
		queue_free()
		print("18层通路已开启，杰克已前往18层")
	)

func start_stage_2(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "杰克", "icon": jack_icon, "text": "祝你好运，勇士！"}
	]
	get_tree().root.add_child(ui)
