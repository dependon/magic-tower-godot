extends CharacterBody2D

#生命
@export var hp: int = 1000
#攻击
@export var atk: int = 10
#攻击
@export var def: int = 10
#金币
@export var gold: int = 0
#经验
@export var experience: int = 0
#等级
@export var level: int = 1
#黄色钥匙数量
@export var key_yellow: int = 0
#蓝色钥匙数量
@export var key_blue: int = 0
#红色钥匙数量
@export var key_red: int = 0
#是否正在与npc对话
var is_talking: bool = false
#角色移动的像素
const GRID_SIZE = 32
#角色每秒移动间隔
const MOVE_DELAY = 0.05 # 移动间隔时间（秒）
#在穿越楼层的时候，防止过快，穿模到墙体里面，做了个进入新楼层0.2s不能移动
var move_timer = 0.2

@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D

func _ready():
	# 从全局加载状态
	Global.load_player_state(self)
	
	# 如果是从存档恢复，且没有待处理的传送目标，则设置位置
	# 如果有 target_portal_id，则由 floor_up.gd 的 _teleport_player 处理
	if Global.should_restore_pos and Global.target_portal_id == "":
		global_position = Global.player_saved_pos
		# 确保对齐网格中心
		global_position.x = floor(global_position.x / GRID_SIZE) * GRID_SIZE + GRID_SIZE / 2.0
		global_position.y = floor(global_position.y / GRID_SIZE) * GRID_SIZE + GRID_SIZE / 2.0
		Global.should_restore_pos = false
	
	# 确保 RayCast2D 长度为一个网格大小
	ray.target_position = Vector2(0, GRID_SIZE)
	ray.enabled = true
	
	# 刚进入楼层时，增加一个短时间的移动缓冲，防止因为长按按键导致穿墙
	move_timer = 0.2

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

func move_in_direction(dir: Vector2):
	# 更新射线方向
	ray.target_position = dir * GRID_SIZE
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		# 无障碍，移动并确保对齐网格中心
		var target_pos = position + dir * GRID_SIZE
		target_pos.x = floor(target_pos.x / GRID_SIZE) * GRID_SIZE + GRID_SIZE / 2.0
		target_pos.y = floor(target_pos.y / GRID_SIZE) * GRID_SIZE + GRID_SIZE / 2.0
		position = target_pos
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
		Global.show_message("Game Over")

# 获得奖励函数
func add_rewards(g: int, e: int):
	gold += g
	experience += e
	var msg = "获得金币: %d, 经验: %d" % [g, e]
	Global.show_message(msg)
