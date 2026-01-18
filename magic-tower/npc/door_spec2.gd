extends Area2D

func _ready():
	# 如果杰克已经去开启通路了（阶段 2），则这些门消失
	if Global.jack_quest_stage >= 2:
		queue_free()
