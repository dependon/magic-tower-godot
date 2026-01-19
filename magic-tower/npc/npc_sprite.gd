extends Area2D

@onready var dialogue_ui_scene = preload("res://npc/ui/dialogue_ui.tscn")
@onready var hero_tex = preload("res://images/hero.png")
@onready var npc_tex = preload("res://images/npcs.png")

var warrior_icon = AtlasTexture.new()
var fairy_icon = AtlasTexture.new()

var is_finished = false

func _ready():
	# 初始化头像
	warrior_icon.atlas = hero_tex
	warrior_icon.region = Rect2(0, 0, 32, 32)
	
	fairy_icon.atlas = npc_tex
	fairy_icon.region = Rect2(0, 96, 32, 32) # 假设仙子在 npcs.png 的位置
	
	# 检查任务阶段
	if Global.fairy_quest_stage >= 2:
		queue_free()
		return
		
	# 检查是否已经完成了初始剧情
	if Global.is_defeated(self):
		is_finished = true
		position.x -= 32 # 保持在移动后的位置

func interact(player):
	if Global.fairy_quest_stage >= 2:
		return
		
	if not is_finished:
		start_dialogue(player)
	elif Global.fairy_quest_stage == 0:
		start_cross_quest_dialogue(player)
	elif Global.fairy_quest_stage == 1:
		if Global.has_cross:
			complete_cross_quest_dialogue(player)
		else:
			# 重复提示寻找十字架
			start_cross_quest_dialogue(player)

func start_dialogue(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	
	# 准备对话队列
	ui.dialogue_queue = [
		{"name": "仙子", "icon": fairy_icon, "text": "您醒了!"},
		{"name": "勇士", "icon": warrior_icon, "text": "我是谁，这是在哪", "name_color": Color.YELLOW},
		{"name": "仙子", "icon": fairy_icon, "text": "我是这里的仙子，你被小怪打晕了"},
		{"name": "勇士", "icon": warrior_icon, "text": "剑，我的剑呢", "name_color": Color.YELLOW},
		{"name": "仙子", "icon": fairy_icon, "text": "你的剑被抢走了，我只能先救你出来"},
		{"name": "勇士", "icon": warrior_icon, "text": "我要去救公主", "name_color": Color.YELLOW}
	]
	
	get_tree().root.add_child(ui)
	
	# 监听对话结束信号
	ui.dialogue_finished.connect(func(): 
		end_dialogue(player)
	)

func start_cross_quest_dialogue(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "仙子", "icon": fairy_icon, "text": "帮我找寻十字架，拥有十字架，我会给你提升1/3的属性和打开21层的路"}
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func():
		Global.fairy_quest_stage = 1
	)

func complete_cross_quest_dialogue(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "仙子", "icon": fairy_icon, "text": "太好了，你找到了十字架！"},
		{"name": "仙子", "icon": fairy_icon, "text": "我现在就为你提升属性，并打开通往21层的道路。"},
		{"name": "勇士", "icon": warrior_icon, "text": "多谢仙子！", "name_color": Color.YELLOW}
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func():
		# 提升 1/3 属性
		player.hp = int(player.hp * 4.0 / 3.0)
		player.atk = int(player.atk * 4.0 / 3.0)
		player.def = int(player.def * 4.0 / 3.0)
		
		Global.save_player_state(player)
		Global.fairy_quest_stage = 2
		Global.register_defeated(self)
		
		# 打开21层的路 (通过全局变量控制，Map20 会读取这个变量)
		# 仙子消失
		queue_free()
	)

func end_dialogue(player):
	is_finished = true
	# 记录剧情完成状态
	Global.register_defeated(self)
	
	# 给玩家发放奖励：红黄蓝钥匙各一把
	player.key_yellow += 1
	player.key_blue += 1
	player.key_red += 1
	print("获得奖励：黄钥匙x1, 蓝钥匙x1, 红钥匙x1")
	
	# 向左移动 32px 的平滑动画
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 32, 0.5).set_trans(Tween.TRANS_SINE)
