extends Area2D

@onready var dialogue_ui_scene = preload("res://npc/ui/dialogue_ui.tscn")
@onready var npc_tex = preload("res://images/npcs.png")

var old_man_icon = AtlasTexture.new()
var is_interacted = false

func _ready():
	# 检查是否已经交互过
	if Global.is_defeated(self):
		queue_free()
		return
		
	old_man_icon.atlas = npc_tex
	old_man_icon.region = Rect2(0, 32, 32, 32) # npc_atk1 在 npcs.png 中的位置

func interact(player):
	if is_interacted or player.is_talking:
		return
		
	is_interacted = true
	player.is_talking = true
	
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "神秘老人", "icon": old_man_icon, "text": "谢谢你救了我，我会给你30防御力"}
	]
	get_tree().root.add_child(ui)
	
	ui.dialogue_finished.connect(func(): 
		# 给玩家加成
		player.def += 30
		Global.save_player_state(player) # 立即保存状态
		
		# 渐隐消失
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		tween.finished.connect(func():
			Global.register_defeated(self)
			queue_free()
		)
	)
