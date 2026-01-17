extends Area2D

func _ready():
	# 检查该对象是否已被标记为消失（通过 Global.register_defeated 或手动 ID）
	if Global.is_defeated(self):
		queue_free()
