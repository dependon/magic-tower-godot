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
	
	# 检查是否已经完成了剧情
	if Global.is_defeated(self):
		is_finished = true
		position.x -= 32 # 保持在移动后的位置

func interact(player):
	if is_finished:
		return
		
	start_dialogue(player)

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
