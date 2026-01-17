extends CharacterBody2D

@export var hp: int = 1000
@export var atk: int = 10
@export var def: int = 10
@export var gold: int = 0
@export var experience: int = 0
@export var level: int = 1
@export var key_yellow: int = 0
@export var key_blue: int = 0
@export var key_red: int = 0

var is_talking: bool = false

const GRID_SIZE = 32
const MOVE_DELAY = 0.05 # 移动间隔时间（秒）
var move_timer = 0.0

@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D

func _ready():
	# 从全局加载状态
	Global.load_player_state(self)
	
	# 确保 RayCast2D 长度为一个网格大小
	ray.target_position = Vector2(0, GRID_SIZE)
	ray.enabled = true

func _physics_process(delta):
	if is_talking:
		move_timer = 0
		return
		
	if move_timer > 0:
		move_timer -= delta
		return
		
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction = Vector2.UP
		sprite.play("up")
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
		sprite.play("down")
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
		sprite.play("left")
	elif Input.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT
		sprite.play("right")
	
	if direction != Vector2.ZERO:
		move_in_direction(direction)
		move_timer = MOVE_DELAY

func _unhandled_input(event):
	# 移除了原有的移动逻辑，改在 _physics_process 中处理
	pass

func move_in_direction(dir: Vector2):
	# 更新射线方向
	ray.target_position = dir * GRID_SIZE
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		# 无障碍，直接移动
		position += dir * GRID_SIZE
	else:
		# 碰到障碍，检查碰撞体
		var collider = ray.get_collider()
		if collider.has_method("interact"):
			collider.interact(self)
		elif collider is TileMapLayer:
			# 如果是墙壁或其他地图层（暂不处理，魔塔中墙壁通常不可通过）
			pass

# 玩家受伤函数
func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		hp = 0
		print("Game Over")

# 获得奖励函数
func add_rewards(g: int, e: int):
	gold += g
	experience += e
	print("获得金币: %d, 经验: %d" % [g, e])
