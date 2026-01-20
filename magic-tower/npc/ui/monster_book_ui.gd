extends CanvasLayer

@onready var slots_container = $Control/Panel/ScrollContainer/VBoxContainer
@onready var page_label = $Control/Panel/PageLabel

var player = null
var monster_list = []

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_talking = true
	
	refresh_monster_list()

func refresh_monster_list():
	# 获取当前场景中所有的怪物
	var all_enemies = get_tree().get_nodes_in_group("enemy")
	
	# 提取怪物属性，去重（同种怪物只显示一次）
	var seen_monsters = {}
	monster_list = []
	
	for enemy in all_enemies:
		if not enemy.is_visible_in_tree(): continue
		
		var m_id = enemy.id
		if not seen_monsters.has(m_id):
			var info = {
				"name": enemy.enemy_name,
				"hp": enemy.hp,
				"atk": enemy.atk,
				"def": enemy.def,
				"gold": enemy.gold,
				"exp": enemy.experience,
				"sprite_frames": enemy.animated_sprite.sprite_frames,
				"animation": enemy.idle_animation,
				"pre_battle_damage": enemy.pre_battle_damage,
				"life_drain_percent": enemy.life_drain_percent
			}
			seen_monsters[m_id] = info
			monster_list.append(info)
	
	# 按伤害排序（可选）
	# monster_list.sort_custom(func(a, b): return _calc_damage(a) < _calc_damage(b))
	
	display_monsters()

func display_monsters():
	# 清理旧列表
	for child in slots_container.get_children():
		child.queue_free()
	
	for info in monster_list:
		var row = create_monster_row(info)
		slots_container.add_child(row)
	
	# 更新页码 (这里暂时显示 1/1)
	page_label.text = "1 / 1"

func create_monster_row(info):
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(380, 90)
	
	var h_box = HBoxContainer.new()
	h_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
	panel.add_child(h_box)
	
	# 怪物图标
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(64, 64)
	icon_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# 给图标加个框
	var icon_bg = ColorRect.new()
	icon_bg.size = Vector2(40, 40)
	icon_bg.position = Vector2(12, 12)
	icon_bg.color = Color(1, 1, 1, 0.1)
	icon_container.add_child(icon_bg)
	
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.sprite_frames = info.sprite_frames
	animated_sprite.play(info.animation)
	animated_sprite.position = Vector2(32, 32)
	animated_sprite.scale = Vector2(1.2, 1.2)
	icon_container.add_child(animated_sprite)
	h_box.add_child(icon_container)
	
	# 名字和基本属性
	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = info.name
	name_label.add_theme_font_size_override("font_size", 18)
	main_vbox.add_child(name_label)
	
	var stats_grid = GridContainer.new()
	stats_grid.columns = 3
	stats_grid.add_theme_constant_override("h_separation", 15)
	
	var p_atk = player.atk if player else Global.atk
	var p_def = player.def if player else Global.def
	var p_hp = player.hp if player else Global.hp
	
	var damage = _calculate_expected_damage(info, p_atk, p_def, p_hp)
	var critical = _calculate_critical(info, p_atk, p_def)
	var def_reduction = _calculate_def_reduction(info, p_atk, p_def)
	
	# 第一行: 生命 攻击 防御
	stats_grid.add_child(_create_stat_label("生命", info.hp))
	stats_grid.add_child(_create_stat_label("攻击", info.atk))
	stats_grid.add_child(_create_stat_label("防御", info.def))
	
	# 第二行: 金币 经验 伤害
	stats_grid.add_child(_create_stat_label("金币", info.gold))
	stats_grid.add_child(_create_stat_label("经验", info.exp))
	
	var dmg_label = _create_stat_label("伤害", damage)
	if damage == -1:
		dmg_label.get_child(1).text = "???"
		dmg_label.get_child(1).modulate = Color.RED
	elif damage == 0:
		dmg_label.get_child(1).modulate = Color.GREEN
	stats_grid.add_child(dmg_label)
	
	# 第三行: 临界 减伤 1防 或 特殊属性
	if info.life_drain_percent > 0 or info.pre_battle_damage > 0:
		if info.life_drain_percent > 0:
			stats_grid.add_child(_create_stat_label("吸血", str(int(info.life_drain_percent * 100)) + "%"))
		
		if info.pre_battle_damage > 0:
			stats_grid.add_child(_create_stat_label("固伤", info.pre_battle_damage))
		
		# 填充剩余格子以保持布局对齐（如果只有1个特殊属性）
		var child_count = stats_grid.get_child_count()
		while child_count % 3 != 0:
			stats_grid.add_child(Control.new())
			child_count += 1
	else:
		stats_grid.add_child(_create_stat_label("临界", critical))
		stats_grid.add_child(_create_stat_label("减伤", 0)) # 减伤暂时设为0
		stats_grid.add_child(_create_stat_label("1防", def_reduction))
	
	main_vbox.add_child(stats_grid)
	h_box.add_child(main_vbox)
	
	return panel

func _create_stat_label(label_text, value):
	var hbox = HBoxContainer.new()
	var l = Label.new()
	l.text = label_text
	l.add_theme_font_size_override("font_size", 12)
	l.modulate = Color(0.8, 0.8, 0.8)
	
	var v = Label.new()
	v.text = str(value)
	v.add_theme_font_size_override("font_size", 12)
	
	hbox.add_child(l)
	hbox.add_child(v)
	return hbox

func _calculate_expected_damage(info, p_atk, p_def, p_hp) -> int:
	var damage_to_enemy = p_atk - info.def
	if damage_to_enemy <= 0: return -1
	
	var damage_to_player = info.atk - p_def
	if damage_to_player < 0: damage_to_player = 0
	
	var turns = ceil(float(info.hp) / damage_to_enemy)
	var total_damage = (turns - 1) * damage_to_player
	
	total_damage += info.pre_battle_damage
	if info.life_drain_percent > 0:
		total_damage += int(p_hp * info.life_drain_percent)
		
	return int(total_damage)

func _calculate_critical(info, p_atk, p_def) -> int:
	var damage_to_enemy = p_atk - info.def
	if damage_to_enemy <= 0: return 0
	
	var turns = ceil(float(info.hp) / damage_to_enemy)
	if turns <= 1: return 0
	
	var next_turns = turns - 1
	var needed_atk = ceil(float(info.hp) / next_turns) + info.def
	return int(needed_atk - p_atk)

func _calculate_def_reduction(info, p_atk, p_def) -> int:
	var damage_to_enemy = p_atk - info.def
	if damage_to_enemy <= 0: return 0
	
	var turns = ceil(float(info.hp) / damage_to_enemy)
	if turns <= 1: return 0
	
	if info.atk - p_def <= 0: return 0
	
	return int(turns - 1)

func _on_close_button_pressed():
	if player:
		player.is_talking = false
	queue_free()
