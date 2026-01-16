extends Area2D

var dialogues = [
	{"name": "fairy", "text": "您醒了!"},
	{"name": "player", "text": "我是谁，这是在哪"},
	{"name": "fairy", "text": "我是这里的仙子，你被小怪打晕了"},
	{"name": "player", "text": "剑，我的剑呢"},
	{"name": "fairy", "text": "你的剑被抢走了，我只能先救你出来"},
	{"name": "player", "text": "我要去救公主"}
]

var current_dialogue_index = 0
var is_active = false
var is_finished = false
var bubble_instance = null
var current_player = null

@onready var bubble_scene = preload("res://npc/dialogue_bubble.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
		
	# 如果正在对话，监听任何移动或确认键来推进对话
	if event.is_action_pressed("ui_accept") or \
	   event.is_action_pressed("ui_up") or \
	   event.is_action_pressed("ui_down") or \
	   event.is_action_pressed("ui_left") or \
	   event.is_action_pressed("ui_right"):
		# 标记输入已处理，防止触发其他逻辑
		get_viewport().set_input_as_handled()
		next_dialogue()

func _ready():
	# 检查是否已经完成了剧情
	if Global.is_defeated(self):
		is_finished = true
		position.x -= 32 # 保持在移动后的位置

func interact(player):
	if is_finished:
		return # 剧情结束后不再触发
		
	if is_active:
		next_dialogue()
		return
		
	start_dialogue(player)

func start_dialogue(player):
	is_active = true
	current_player = player
	current_player.is_talking = true
	current_dialogue_index = 0
	show_dialogue()

func next_dialogue():
	current_dialogue_index += 1
	if current_dialogue_index >= dialogues.size():
		end_dialogue()
	else:
		show_dialogue()

func show_dialogue():
	if bubble_instance:
		bubble_instance.queue_free()
		
	var data = dialogues[current_dialogue_index]
	bubble_instance = bubble_scene.instantiate()
	
	# 设置文本
	var label = bubble_instance.get_node("PanelContainer/Label")
	label.text = data["text"]
	
	# 决定显示在谁头上
	if data["name"] == "fairy":
		add_child(bubble_instance)
		bubble_instance.position = Vector2(0, -25) # NPC 上方
	else:
		current_player.add_child(bubble_instance)
		bubble_instance.position = Vector2(0, -25) # Player 上方

func end_dialogue():
	if bubble_instance:
		bubble_instance.queue_free()
	
	is_active = false
	if current_player:
		current_player.is_talking = false
	
	is_finished = true
	# 记录剧情完成状态
	Global.register_defeated(self)
	
	# 给玩家发放奖励：红黄蓝钥匙各一把
	if current_player:
		current_player.key_yellow += 1
		current_player.key_blue += 1
		current_player.key_red += 1
		print("获得奖励：黄钥匙x1, 蓝钥匙x1, 红钥匙x1")
	
	# 向左移动 32px 的平滑动画
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 32, 0.5).set_trans(Tween.TRANS_SINE)
