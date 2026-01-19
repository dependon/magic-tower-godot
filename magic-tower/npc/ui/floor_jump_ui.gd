extends CanvasLayer

@onready var preview_viewport = $Control/Panel/PreviewContainer/SubViewportContainer/SubViewport
@onready var floor_label = $Control/Panel/FloorSelection/FloorLabel
@onready var up_btn = $Control/Panel/FloorSelection/UpButton
@onready var down_btn = $Control/Panel/FloorSelection/DownButton

var unlocked_floors: Array[String] = []
var current_select_index: int = 0
var player = null

func _ready():
	# 获取已解锁楼层并排序
	unlocked_floors = Global.unlocked_floors.duplicate()
	# 确保当前楼层也在列表中
	if Global.floor_name not in unlocked_floors:
		unlocked_floors.append(Global.floor_name)
	
	# 按照数值排序
	unlocked_floors.sort_custom(func(a, b): return a.to_int() < b.to_int())
	
	# 找到当前楼层在列表中的索引
	current_select_index = unlocked_floors.find(Global.floor_name)
	if current_select_index == -1:
		current_select_index = 0
		
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_talking = true # 停止玩家移动
		
	update_ui()

func _input(event):
	if event.is_action_pressed("ui_up"):
		_on_up_button_pressed()
	elif event.is_action_pressed("ui_down"):
		_on_down_button_pressed()
	elif event.is_action_pressed("ui_accept"):
		_on_jump_button_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_close_button_pressed()

func update_ui():
	if unlocked_floors.size() == 0:
		floor_label.text = "未解锁任何楼层"
		return
		
	var f_name = unlocked_floors[current_select_index]
	floor_label.text = "主塔 " + f_name + " 层"
	
	# 更新预览
	load_preview(f_name)
	
	# 更新按钮状态 (可选，如果是键盘操作则不一定需要禁用)
	# up_btn.disabled = current_select_index >= unlocked_floors.size() - 1
	# down_btn.disabled = current_select_index <= 0

func load_preview(f_name: String):
	# 清理旧预览
	for child in preview_viewport.get_children():
		child.queue_free()
		
	var scene_path = "res://map/map" + f_name + ".tscn"
	if ResourceLoader.exists(scene_path):
		var scene_resource = load(scene_path)
		var scene = scene_resource.instantiate()
		preview_viewport.add_child(scene)
		
		# 添加摄像机以正确显示预览
		var camera = Camera2D.new()
		preview_viewport.add_child(camera)
		# 居中摄像机 (11x32 / 2 = 176)
		camera.position = Vector2(176, 176)
		
		# 计算缩放以适配预览窗口 (352 -> 288)
		var zoom_factor = 288.0 / 352.0
		camera.zoom = Vector2(zoom_factor, zoom_factor)
		camera.make_current()
		
		# 禁用预览场景中的脚本处理，防止怪物移动、触发剧情等
		_disable_all_scripts(scene)
		
		# 移除预览中的 HUD 或 Player 等不需要显示的节点
		for child in scene.get_children():
			if child.name == "HUD" or child.is_in_group("player"):
				child.hide()
				child.process_mode = Node.PROCESS_MODE_DISABLED
		
		# 强制设置预览位置，避免因为地图本身的 position.x = 160 导致偏移
		scene.position = Vector2.ZERO

func _disable_all_scripts(node: Node):
	node.process_mode = Node.PROCESS_MODE_DISABLED
	for child in node.get_children():
		_disable_all_scripts(child)

func _on_up_button_pressed():
	if current_select_index < unlocked_floors.size() - 1:
		current_select_index += 1
		update_ui()

func _on_down_button_pressed():
	if current_select_index > 0:
		current_select_index -= 1
		update_ui()

func _on_jump_button_pressed():
	if unlocked_floors.size() == 0:
		return
		
	var target_floor = unlocked_floors[current_select_index]
	var target_scene = "res://map/map" + target_floor + ".tscn"
	
	if target_floor == Global.floor_name:
		_on_close_button_pressed()
		return
		
	if ResourceLoader.exists(target_scene):
		if player:
			Global.save_player_state(player)
		
		# 跳跃时，我们不指定 portal_id，让地图使用默认位置，或者可以寻找特定点
		# 这里的简化处理是直接切换场景
		Global.floor_name = target_floor
		get_tree().change_scene_to_file(target_scene)
		queue_free()

func _on_close_button_pressed():
	if player:
		player.is_talking = false
	queue_free()
