extends Area2D
class_name Enemy

# 怪物基本属性
@export_group("Stats")
@export var id: String = "green slime"
@export var enemy_name: String = "green slime"
@export var hp: int = 50
@export var atk: int = 20
@export var def: int = 1
@export var gold: int = 1
@export var experience: int = 1

# 特殊属性
@export_group("Special Traits")
@export var pre_battle_damage: int = 0 # 固伤：开局前直接扣除
@export var life_drain_percent: float = 0.0 # 吸血：百分比扣除玩家当前血量 (例如 0.25 表示 25%)

# 动画节点引用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_label: Label = $DamageLabel

@export var idle_animation: String = "default"

func _ready() -> void:
	add_to_group("enemy")
	# 检查是否已经被击败
	if Global.is_defeated(self):
		queue_free()
		return
		
	# 播放指定的初始动画
	if animated_sprite.sprite_frames.has_animation(idle_animation):
		animated_sprite.play(idle_animation)
		
	# 初始化逻辑，例如根据ID加载配置（如果后续有全局配置表）
	update_damage_display()

func _process(_delta: float) -> void:
	# 实时更新伤害显示（实际项目中建议通过信号优化性能）
	update_damage_display()

func update_damage_display() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		damage_label.text = "???"
		return
		
	var p_atk = player.atk if "atk" in player else 0
	var p_def = player.def if "def" in player else 0
	var p_hp = player.hp if "hp" in player else 0
	
	var damage = get_expected_damage(p_atk, p_def, p_hp)
	
	if damage == -1:
		damage_label.text = "???"
		damage_label.modulate = Color.RED
	elif damage == 0:
		damage_label.text = "0"
		damage_label.modulate = Color.GREEN
	else:
		damage_label.text = str(damage)
		damage_label.modulate = Color.WHITE

# 计算战斗伤害预览
# player_atk: 玩家攻击力
# player_def: 玩家防御力
# player_hp: 玩家当前生命值
# 返回: 玩家将受到的总伤害。如果无法破防，返回 -1
func get_expected_damage(player_atk: int, player_def: int, player_hp: int = 0) -> int:
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
	
	# 加上特殊属性伤害
	total_damage += pre_battle_damage # 固伤
	# 吸血：按玩家当前血量的百分比扣除（取整）
	if life_drain_percent > 0:
		total_damage += int(player_hp * life_drain_percent)
	
	return int(total_damage)

# 与玩家进行战斗交互
# player: 玩家节点对象，预期拥有 hp, atk, def, gold, experience 等属性或方法
func interact(player) -> void:
	# 这里假设 player 脚本有对应的属性或方法
	# 为了健壮性，这里应该检查 player 是否有效
	
	var p_atk = player.atk if "atk" in player else 0
	var p_def = player.def if "def" in player else 0
	var p_hp = player.hp if "hp" in player else 0
	
	var expected_damage = get_expected_damage(p_atk, p_def, p_hp)
	
	if expected_damage == -1:
		print("无法击败 " + enemy_name + " (无法破防)")
		return
		
	if p_hp <= expected_damage:
		print("无法击败 " + enemy_name + " (生命值不足)")
		return
		
	# 执行战斗结算
	print("击败了 " + enemy_name + "，受到伤害: " + str(expected_damage))
	Global.play_sound("res://sounds/attack.ogg")
	
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
	
	# 如果是魔神且在24层，弹出通关对话
	if (id == "dark_god" or id == "dark_god2") and Global.floor_name == "24":
		trigger_ending_dialogue(player)
	else:
		# 播放死亡动画或音效，然后销毁自己
		die(player)

func trigger_ending_dialogue(player):
	if not player: return
	player.is_talking = true
	
	# 隐藏魔神，防止对话时还在场
	visible = false
	# 禁用碰撞，防止重复触发
	$CollisionShape2D.set_deferred("disabled", true)
	
	var dialogue_ui_scene = load("res://npc/ui/dialogue_ui.tscn")
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "系统", "icon": null, "text": "魔王已经被彻底击败于塔内，魔塔即将消散，你带着公主离开了魔塔"},
		{"name": "系统", "icon": null, "text": "恭喜你，通关本游戏，感谢你的游玩"}
	]
	
	# 先连接信号，再添加到场景树，防止 _ready 中可能发射的信号丢失
	ui.dialogue_finished.connect(func():
		if is_instance_valid(player):
			player.is_talking = false
		
		# 记录击败状态
		Global.register_defeated(self)
		
		# 延迟切换场景，确保 UI 已经安全关闭
		get_tree().call_deferred("change_scene_to_file", "res://main_menu.tscn")
	)
	
	get_tree().root.add_child(ui)

func die(player = null) -> void:
	# 记录击败状态，防止切换楼层后刷新
	Global.register_defeated(self)
	
	# 如果提供了玩家引用，则保存其状态
	if player:
		Global.save_player_state(player)
		
	# 可以在这里添加死亡动画逻辑
	# 暂时直接删除节点
	queue_free()
