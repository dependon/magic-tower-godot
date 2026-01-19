extends CanvasLayer

enum Mode { SAVE, LOAD }
var current_mode = Mode.SAVE
var current_page = 0
const SLOTS_PER_PAGE = 6
const TOTAL_PAGES = 5

@onready var title_label = $Control/Panel/Title
@onready var slots_container = $Control/Panel/SlotsGrid
@onready var page_label = $Control/Panel/Pagination/PageLabel

func _ready():
	setup_ui()

func set_mode(mode: Mode):
	current_mode = mode
	if is_inside_tree():
		title_label.text = "存档" if current_mode == Mode.SAVE else "读档"
		refresh_slots()

func setup_ui():
	title_label.text = "存档" if current_mode == Mode.SAVE else "读档"
	refresh_slots()
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_talking = true

func refresh_slots():
	page_label.text = str(current_page + 1) + "/" + str(TOTAL_PAGES)
	
	for i in range(SLOTS_PER_PAGE):
		var slot_id = current_page * SLOTS_PER_PAGE + i
		var slot_node = slots_container.get_child(i)
		var info = Global.get_save_info(slot_id)
		
		var screenshot_rect = slot_node.get_node("VBoxContainer/TextureRect")
		var name_label = slot_node.get_node("VBoxContainer/SlotName")
		var time_label = slot_node.get_node("VBoxContainer/Timestamp")
		
		# 设置显示名称
		if slot_id == 0:
			name_label.text = "自动存档"
		else:
			name_label.text = ("存档" if current_mode == Mode.SAVE else "读档") + str(slot_id)
			
		if info:
			time_label.text = info.timestamp
			if FileAccess.file_exists(info.screenshot):
				var img = Image.load_from_file(info.screenshot)
				var tex = ImageTexture.create_from_image(img)
				screenshot_rect.texture = tex
		else:
			time_label.text = "无存档数据"
			screenshot_rect.texture = null

func _on_slot_pressed(index_on_page: int):
	var slot_id = current_page * SLOTS_PER_PAGE + index_on_page
	
	if current_mode == Mode.SAVE:
		# 自动存档位 (0) 不允许手动保存
		if slot_id == 0: return
		
		# 隐藏界面以抓取干净的截图
		visible = false
		await Global.save_game(slot_id)
		visible = true
		
		refresh_slots()
	else:
		if Global.load_game(slot_id):
			queue_free()
		else:
			print("加载失败，存档可能不存在")

func _on_prev_page_pressed():
	if current_page > 0:
		current_page -= 1
		refresh_slots()

func _on_next_page_pressed():
	if current_page < TOTAL_PAGES - 1:
		current_page += 1
		refresh_slots()

func _on_close_button_pressed():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_talking = false
	queue_free()
