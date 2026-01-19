extends Node2D

func _ready():
	# 根据是否封印显示对应的 Boss
	if $dark_god and $dark_god2:
		if Global.is_boss_sealed:
			$dark_god.visible = false
			# 禁用未封印 Boss 的碰撞
			var col1 = $dark_god.get_node_or_null("CollisionShape2D")
			if col1: col1.disabled = true
			
			$dark_god2.visible = true
			var col2 = $dark_god2.get_node_or_null("CollisionShape2D")
			if col2: col2.disabled = false
		else:
			$dark_god.visible = true
			var col1 = $dark_god.get_node_or_null("CollisionShape2D")
			if col1: col1.disabled = false
			
			$dark_god2.visible = false
			var col2 = $dark_god2.get_node_or_null("CollisionShape2D")
			if col2: col2.disabled = true
