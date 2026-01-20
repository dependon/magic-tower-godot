extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

var is_opening = false

func _ready():
	# 检查是否已经开启过
	if Global.is_defeated(self):
		queue_free()
		return
	
	sprite.play("default")
	# 连接动画结束信号
	sprite.animation_finished.connect(_on_animation_finished)

func interact(_player):
	if is_opening:
		return
		
	open_door()

func open_door():
	Global.play_sound("res://sounds/door.ogg")
	is_opening = true
	# 立即禁用碰撞，让玩家可以通过
	collision.set_deferred("disabled", true)
	sprite.play("open")

func _on_animation_finished():
	if sprite.animation == "open":
		# 注册已消失
		Global.register_defeated(self)
		queue_free()
