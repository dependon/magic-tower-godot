extends Area2D
class_name FloorUp

@export var target_scene: String = "res://map/map0.tscn"
@export var portal_id: String = "p1"  # 当前传送门的唯一ID
@export var target_portal_id: String = "p2"  # 目标场景中传送门的ID

@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# 设置传送门的碰撞检测层
	collision_layer = 0
	collision_mask = 1  # 检测玩家层
