extends Node2D

func _ready():
	# 根据公主对话状态设置楼梯可见性
	if $floor_up:
		$floor_up.visible = Global.princess_dialogue_finished
		# 如果 floor_up 有 collision，也要根据状态设置
		var collision = $floor_up.get_node_or_null("CollisionShape2D")
		if collision:
			collision.disabled = !Global.princess_dialogue_finished
	
	# 处理 18 层的特殊门 door_spec2 (杰克任务)
	if Global.jack_quest_stage >= 2:
		for child in get_children():
			if child.name.begins_with("door_spec2"):
				child.queue_free()
			if child.name.begins_with("door_spec3"):
				child.queue_free()
