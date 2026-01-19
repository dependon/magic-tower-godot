extends Node2D

func _ready():
	# 检查杰克任务状态，如果已经对话过，确保 door_spec 消失
	if Global.jack_quest_stage >= 1:
		var door = get_node_or_null("door_spec")
		if door:
			door.queue_free()
