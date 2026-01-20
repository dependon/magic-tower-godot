extends CanvasLayer

@onready var btn_container = $Control/Panel/VBoxContainer
@onready var player = get_tree().get_first_node_in_group("player")

# 商店配置信息
var shops = [
	{"id": "shop_3f_gold", "name": "3F金币商店", "scene": "res://npc/ui/shop_ui.tscn"},
	{"id": "shop_5f_exp", "name": "5F经验商店", "scene": "res://npc/ui/shop_exp_ui.tscn"},
	{"id": "shop_5f_key", "name": "5F钥匙商人", "scene": "res://npc/ui/shop_key_ui.tscn"},
	{"id": "shop_11f_gold", "name": "11F金币商店", "scene": "res://npc/ui/shop_ui2.tscn"},
	{"id": "shop_13f_exp", "name": "13F经验商店", "scene": "res://npc/ui/shop_exp_ui2.tscn"}
]

func _ready():
	if player:
		player.is_talking = true
	
	setup_buttons()

func setup_buttons():
	# 清空容器
	for child in btn_container.get_children():
		child.queue_free()
		
	# 创建商店按钮
	for shop in shops:
		var btn = Button.new()
		btn.text = shop.name
		btn.custom_minimum_size = Vector2(0, 45)
		
		# 检查是否解锁
		var is_unlocked = Global.unlocked_shops.get(shop.id, false)
		btn.disabled = !is_unlocked
		
		if is_unlocked:
			btn.pressed.connect(_on_shop_btn_pressed.bind(shop))
		else:
			# 置灰样式可以通过 disabled 属性自动处理，也可以额外设置 modulate
			btn.modulate = Color(0.5, 0.5, 0.5, 0.8)
			
		btn_container.add_child(btn)
	
	# 添加返回按钮
	var back_btn = Button.new()
	back_btn.text = "返回游戏"
	back_btn.custom_minimum_size = Vector2(0, 45)
	back_btn.pressed.connect(_on_close_pressed)
	btn_container.add_child(back_btn)

func _on_shop_btn_pressed(shop_info):
	# 关闭快捷商店界面
	_on_close_pressed()
	
	# 延迟实例化目标商店 UI，确保上一个 UI 已完全移除且 player.is_talking 状态正确
	await get_tree().process_frame
	
	if player:
		player.is_talking = true
		var shop_scene = load(shop_info.scene)
		var shop_instance = shop_scene.instantiate()
		shop_instance.player = player
		get_tree().root.add_child(shop_instance)

func _on_close_pressed():
	if player:
		player.is_talking = false
	queue_free()
