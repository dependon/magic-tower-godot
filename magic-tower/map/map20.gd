extends Node2D

func _ready():
	# 根据仙子任务阶段决定 21 层楼梯是否可见
	if $floor_up:
		$floor_up.visible = Global.fairy_quest_stage >= 2
		# 如果不可见，也要禁用碰撞
		var collision = $floor_up.get_node_or_null("CollisionShape2D")
		if collision:
			collision.disabled = Global.fairy_quest_stage < 2
