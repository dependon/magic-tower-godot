extends Node

var target_portal_id: String = ""

# 玩家持久化属性
var hp: int = 10000
var atk: int = 10000
var def: int = 10000
var gold: int = 0
var experience: int = 0
var floor_name: String = "0"
var level: int = 1
var key_yellow: int = 0
var key_blue: int = 0
var key_red: int = 0

# 已解锁的楼层（存楼层名，如 "1", "2"）
var unlocked_floors: Array[String] = []

# 任务状态
var has_pickaxe: bool = false
var has_cross: bool = false
var jack_quest_stage: int = 0 # 0: 未见面, 1: 已对话待寻找锄头, 2: 已交还锄头
var fairy_quest_stage: int = 0 # 0: 初始对话已完成, 1: 已交代寻找十字架任务, 2: 任务完成
var princess_dialogue_finished: bool = false

# 记录每个楼层中已消失的对象（怪物、道具、门等）
# 键格式: "场景名:节点路径"
var defeated_objects: Dictionary = {}

func register_defeated(node: Node):
	var key = _get_node_key(node)
	defeated_objects[key] = true

func is_defeated(node: Node) -> bool:
	var key = _get_node_key(node)
	return defeated_objects.has(key)

func _get_node_key(node: Node) -> String:
	var scene_root = node.owner
	if not scene_root:
		scene_root = node.get_tree().current_scene
	
	var scene_name = "Unknown"
	if scene_root:
		# 优先使用文件名作为场景标识，更稳健
		scene_name = scene_root.scene_file_path.get_file().get_basename()
		if scene_name == "":
			scene_name = scene_root.name
			
	# 使用相对场景根节点的路径作为 ID
	var path = ""
	if scene_root and scene_root != node:
		path = str(scene_root.get_path_to(node))
	else:
		path = node.name
		
	return scene_name + ":" + path

# 保存玩家当前状态到全局
func save_player_state(player):
	hp = player.hp
	atk = player.atk
	def = player.def
	gold = player.gold
	experience = player.experience
	if "level" in player: level = player.level
	if "key_yellow" in player: key_yellow = player.key_yellow
	if "key_blue" in player: key_blue = player.key_blue
	if "key_red" in player: key_red = player.key_red

# 将全局状态应用到玩家
func load_player_state(player):
	player.hp = hp
	player.atk = atk
	player.def = def
	player.gold = gold
	player.experience = experience
	if "level" in player: player.level = level
	if "key_yellow" in player: player.key_yellow = key_yellow
	if "key_blue" in player: player.key_blue = key_blue
	if "key_red" in player: player.key_red = key_red

# 记录解锁楼层
func unlock_floor(f_name: String):
	if f_name not in unlocked_floors:
		unlocked_floors.append(f_name)
		# 排序以保持整洁（可选）
		unlocked_floors.sort_custom(func(a, b): return a.to_int() < b.to_int())
		print("解锁楼层: ", f_name)
