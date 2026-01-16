extends Area2D
class_name Enemy

# 怪物基本属性
@export_group("Stats")
@export var id: String = "green slime"
@export var enemy_name: String = "green slime"
@export var hp: int = 10
@export var atk: int = 10
@export var def: int = 1
@export var gold: int = 1
@export var experience: int = 1

# 动画节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# 初始化逻辑，例如根据ID加载配置（如果后续有全局配置表）
	pass

# 计算战斗伤害预览
# player_atk: 玩家攻击力
# player_def: 玩家防御力
# 返回: 玩家将受到的总伤害。如果无法破防，返回 -1
func get_expected_damage(player_atk: int, player_def: int) -> int:
	var damage_to_enemy = player_atk - def
	
	# 如果玩家攻击力小于等于怪物防御力，无法造成伤害
	if damage_to_enemy <= 0:
		return -1 
	
	var damage_to_player = atk - player_def
	if damage_to_player < 0:
		damage_to_player = 0
	
	# 计算需要攻击多少次才能打死怪物
	# ceil(怪物HP / 玩家单次伤害)
	var turns = ceil(float(hp) / damage_to_enemy)
	
	# 玩家先手，所以怪物攻击次数是 回合数 - 1
	var total_damage = (turns - 1) * damage_to_player
	
	return int(total_damage)

# 与玩家进行战斗交互
# player: 玩家节点对象，预期拥有 hp, atk, def, gold, experience 等属性或方法
func interact(player) -> void:
	# 这里假设 player 脚本有对应的属性或方法
	# 为了健壮性，这里应该检查 player 是否有效
	
	var p_atk = player.atk if "atk" in player else 0
	var p_def = player.def if "def" in player else 0
	var p_hp = player.hp if "hp" in player else 0
	
	var expected_damage = get_expected_damage(p_atk, p_def)
	
	if expected_damage == -1:
		print("无法击败 " + enemy_name + " (无法破防)")
		return
		
	if p_hp <= expected_damage:
		print("无法击败 " + enemy_name + " (生命值不足)")
		return
		
	# 执行战斗结算
	print("击败了 " + enemy_name + "，受到伤害: " + str(expected_damage))
	
	# 扣除玩家血量
	if player.has_method("take_damage"):
		player.take_damage(expected_damage)
	elif "hp" in player:
		player.hp -= expected_damage
		
	# 增加玩家金币和经验
	if player.has_method("add_rewards"):
		player.add_rewards(gold, experience)
	else:
		if "gold" in player: player.gold += gold
		if "experience" in player: player.experience += experience
	
	# 播放死亡动画或音效，然后销毁自己
	die()

func die() -> void:
	# 可以在这里添加死亡动画逻辑
	# 暂时直接删除节点
	queue_free()
