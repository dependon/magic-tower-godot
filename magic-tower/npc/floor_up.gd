extends Area2D
class_name FloorUp

@export var target_scene: String = "res://map/map1.tscn"
@export var target_floor_name: String = "1"
@export var portal_id: String = "p1"  # 当前传送门的唯一ID
@export var target_portal_id: String = "p2"  # 目标场景中传送门的ID

@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# 设置传送门的碰撞检测层
	collision_layer = 1 # 允许被射线检测
	collision_mask = 0
	
	# 如果当前门户是传送目标，则将玩家移动到此处
	if Global.target_portal_id == portal_id:
		call_deferred("_teleport_player")

func _teleport_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# 确保传送位置对齐到网格中心（网格大小为32）
		var snapped_pos = global_position
		snapped_pos.x = floor(snapped_pos.x / 32.0) * 32.0 + 16.0
		snapped_pos.y = floor(snapped_pos.y / 32.0) * 32.0 + 16.0
		
		player.global_position = snapped_pos
		Global.target_portal_id = ""

func interact(player):
	if target_scene == "" or target_scene == null:
		print("目标场景未设置")
		return
	
	# 切换楼层时锁定玩家移动，防止在切换瞬间发生穿墙
	if player and "is_talking" in player:
		player.is_talking = true
	
	print("切换楼层到: ", target_scene)
	# 切换前保存玩家状态
	Global.save_player_state(player)
	Global.target_portal_id = target_portal_id
	Global.floor_name = target_floor_name
	get_tree().change_scene_to_file(target_scene)
