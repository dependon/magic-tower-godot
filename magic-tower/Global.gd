extends Node

var target_portal_id: String = ""

# 玩家持久化属性
var hp: int = 1000
var atk: int = 10
var def: int = 10
var gold: int = 0
var experience: int = 0
var floor_name: String = "0"
var level: int = 1
var key_yellow: int = 0
var key_blue: int = 0
var key_red: int = 0

# 已解锁的楼层（存楼层名，如 "1", "2"）
var unlocked_floors: Array[String] = []

# 已解锁的商店
var unlocked_shops: Dictionary = {
	"shop_3f_gold": false,
	"shop_5f_exp": false,
	"shop_5f_key": false,
	"shop_11f_gold": false,
	"shop_13f_exp": false
}

# 任务状态
var has_pickaxe: bool = false
var has_cross: bool = false
var jack_quest_stage: int = 0 # 0: 未见面, 1: 已对话待寻找锄头, 2: 已交还锄头
var fairy_quest_stage: int = 0 # 0: 初始对话已完成, 1: 已交代寻找十字架任务, 2: 任务完成
var fairy2_quest_stage: int = 0 # 21层精灵任务
var has_staff_fire = false
var has_staff_ice = false
var is_boss_sealed = false
var princess_dialogue_finished: bool = false


# 存档恢复用的玩家位置
var player_saved_pos: Vector2 = Vector2.ZERO
var should_restore_pos: bool = false

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

func new_game():
	hp = 1000
	atk = 10
	def = 10
	gold = 0
	experience = 0
	floor_name = "0"
	level = 1
	key_yellow = 0
	key_blue = 0
	key_red = 0
	unlocked_floors = ["0"]
	unlocked_shops = {
		"shop_3f_gold": false,
		"shop_5f_exp": false,
		"shop_5f_key": false,
		"shop_11f_gold": false,
		"shop_13f_exp": false
	}
	has_pickaxe = false
	has_cross = false
	jack_quest_stage = 0
	fairy_quest_stage = 0
	fairy2_quest_stage = 0
	princess_dialogue_finished = false
	defeated_objects = {}
	target_portal_id = ""
	should_restore_pos = false
	has_staff_fire = false
	has_staff_ice = false
	is_boss_sealed = false
	get_tree().change_scene_to_file("res://map/map0.tscn")

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

# --- 存档系统 ---
const SAVE_PATH_TEMPLATE = "user://save_slot_%d.dat"
const SCREENSHOT_PATH_TEMPLATE = "user://save_slot_%d.png"

func can_save() -> bool:
	return floor_name != "23" and floor_name != "24"

func save_game(slot_id: int):
	if not can_save():
		print("当前楼层禁止存档")
		return
		
	# 先保存玩家状态
	var player = get_tree().get_first_node_in_group("player")
	if player:
		save_player_state(player)
	
	# 捕获截屏
	await capture_screenshot(slot_id)
	
	var save_data = {
		"hp": hp,
		"atk": atk,
		"def": def,
		"gold": gold,
		"experience": experience,
		"floor_name": floor_name,
		"level": level,
		"key_yellow": key_yellow,
		"key_blue": key_blue,
		"key_red": key_red,
		"unlocked_floors": unlocked_floors,
		"unlocked_shops": unlocked_shops,
		"has_pickaxe": has_pickaxe,
		"has_cross": has_cross,
		"jack_quest_stage": jack_quest_stage,
		"fairy_quest_stage": fairy_quest_stage,
		"fairy2_quest_stage": fairy2_quest_stage,
		"has_staff_fire":  has_staff_fire,
		"has_staff_ice": has_staff_ice,
		"is_boss_sealed": is_boss_sealed,
		"princess_dialogue_finished": princess_dialogue_finished,
		"defeated_objects": defeated_objects,
		"timestamp": Time.get_datetime_string_from_system(false, false).replace("T", " "),
		"target_portal_id": target_portal_id,
		"player_pos_x": player.global_position.x if player else 0,
		"player_pos_y": player.global_position.y if player else 0
	}
	
	var file = FileAccess.open(SAVE_PATH_TEMPLATE % slot_id, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("游戏已保存到槽位: ", slot_id)

func load_game(slot_id: int):
	var path = SAVE_PATH_TEMPLATE % slot_id
	if not FileAccess.file_exists(path):
		return false
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		# 应用数据
		hp = save_data.get("hp", 1000)
		atk = save_data.get("atk", 10)
		def = save_data.get("def", 10)
		gold = save_data.get("gold", 0)
		experience = save_data.get("experience", 0)
		floor_name = save_data.get("floor_name", "0")
		level = save_data.get("level", 1)
		key_yellow = save_data.get("key_yellow", 0)
		key_blue = save_data.get("key_blue", 0)
		key_red = save_data.get("key_red", 0)
		unlocked_floors = save_data.get("unlocked_floors", [])
		unlocked_shops = save_data.get("unlocked_shops", {
			"shop_3f_gold": false,
			"shop_5f_exp": false,
			"shop_5f_key": false,
			"shop_11f_gold": false,
			"shop_13f_exp": false
		})
		has_pickaxe = save_data.get("has_pickaxe", false)
		has_cross = save_data.get("has_cross", false)
		jack_quest_stage = save_data.get("jack_quest_stage", 0)
		fairy_quest_stage = save_data.get("fairy_quest_stage", 0)
		fairy2_quest_stage= save_data.get("fairy2_quest_stage", 0)
		has_staff_fire= save_data.get("has_staff_fire", false)
		has_staff_ice= save_data.get("has_staff_ice", false)
		is_boss_sealed= save_data.get("is_boss_sealed", false)
		princess_dialogue_finished = save_data.get("princess_dialogue_finished", false)
		defeated_objects = save_data.get("defeated_objects", {})
		
		# 加载存档时，强制让玩家出现在下楼梯位置
		target_portal_id = "FIND_FLOOR_DOWN"
		should_restore_pos = false
		
		# 切换到保存的楼层
		var scene_path = "res://map/map" + floor_name + ".tscn"
		get_tree().change_scene_to_file(scene_path)
		return true
	return false

func capture_screenshot(slot_id: int):
	# 等待当前帧渲染完成
	await get_tree().process_frame
	await get_tree().process_frame
	
	var viewport = get_tree().root.get_viewport()
	var screenshot = viewport.get_texture().get_image()
	
	# 如果 HUD 存在，可以考虑在截图前隐藏它，或者保留
	screenshot.save_png(SCREENSHOT_PATH_TEMPLATE % slot_id)

func get_save_info(slot_id: int):
	var path = SAVE_PATH_TEMPLATE % slot_id
	if not FileAccess.file_exists(path):
		return null
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		return {
			"timestamp": data.get("timestamp", ""),
			"screenshot": SCREENSHOT_PATH_TEMPLATE % slot_id,
			"floor_name": data.get("floor_name", "0")
		}
	return null
