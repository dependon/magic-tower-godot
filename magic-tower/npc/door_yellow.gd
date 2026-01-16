extends Area2D
class_name Door

enum KeyType { YELLOW, BLUE, RED }

@export var required_key: KeyType = KeyType.YELLOW
@export var open_animation: String = "open"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_opening: bool = false

func _ready():
	# 检查门是否已经被打开过
	if Global.is_defeated(self):
		queue_free()
		return
	
	# 确保门在正确的层，可以被玩家的射线检测到
	collision_layer = 1
	collision_mask = 0

# 与玩家交互逻辑
func interact(player):
	if is_opening:
		return
		
	if has_key(player):
		use_key(player)
		open_door()
	else:
		print("没有对应的钥匙！需要: ", KeyType.keys()[required_key])

# 检查玩家是否有对应的钥匙
func has_key(player) -> bool:
	match required_key:
		KeyType.YELLOW:
			return player.key_yellow > 0
		KeyType.BLUE:
			return player.key_blue > 0
		KeyType.RED:
			return player.key_red > 0
	return false

# 消耗玩家的钥匙
func use_key(player):
	match required_key:
		KeyType.YELLOW:
			player.key_yellow -= 1
		KeyType.BLUE:
			player.key_blue -= 1
		KeyType.RED:
			player.key_red -= 1
	
	# 保存玩家钥匙消耗后的状态
	Global.save_player_state(player)
	return

# 执行开门逻辑
func open_door():
	is_opening = true
	# 记录门已打开，下次进入楼层不再显示
	Global.register_defeated(self)
	
	if animated_sprite.sprite_frames.has_animation(open_animation):
		animated_sprite.play(open_animation)
		animated_sprite.animation_finished.connect(_on_animation_finished)
	else:
		# 如果没有开门动画，直接消失
		queue_free()

func _on_animation_finished():
	queue_free()
