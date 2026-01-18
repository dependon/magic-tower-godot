extends Area2D

@onready var dialogue_ui_scene = preload("res://npc/ui/dialogue_ui.tscn")
@onready var hero_tex = preload("res://images/hero.png")
@onready var npc_tex = preload("res://images/npcs.png")

var warrior_icon = AtlasTexture.new()
var princess_icon = AtlasTexture.new()

func _ready():
	warrior_icon.atlas = hero_tex
	warrior_icon.region = Rect2(0, 0, 32, 32)
	
	princess_icon.atlas = npc_tex
	princess_icon.region = Rect2(0, 352, 32, 32)

func interact(player):
	if player.is_talking:
		return
		
	if Global.princess_dialogue_finished:
		start_simple_dialogue(player)
	else:
		start_quest_dialogue(player)

func start_quest_dialogue(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "勇士", "icon": warrior_icon, "text": "公主，我来救你了，请跟我一起离开", "name_color": Color.YELLOW},
		{"name": "公主", "icon": princess_icon, "text": "不要，我自从被他们抓来后，饱受折磨，我身上的诅咒，需要打败魔王才可以解除"},
		{"name": "勇士", "icon": warrior_icon, "text": "刚刚我不是杀了一个红衣魔王吗", "name_color": Color.YELLOW},
		{"name": "公主", "icon": princess_icon, "text": "那充其量是一个小头目，真正的魔王还在楼里"},
		{"name": "远处声音", "icon": null, "text": "有种就上来杀我。", "name_color": Color.RED},
		{"name": "公主", "icon": princess_icon, "text": "快去杀死魔王，帮助我解除身上的诅咒，感谢你，勇士"}
	]
	get_tree().root.add_child(ui)
	ui.dialogue_finished.connect(func(): 
		Global.princess_dialogue_finished = true
		print("公主对话结束，开启18层楼梯")
		# 通知当前场景更新楼梯可见性
		var current_map = get_tree().current_scene
		if current_map and current_map.name == "Map18":
			var floor_up = current_map.get_node_or_null("floor_up")
			if floor_up:
				floor_up.visible = true
				# 如果 floor_up 有 collision，也要开启
				var collision = floor_up.get_node_or_null("CollisionShape2D")
				if collision:
					collision.disabled = false
	)

func start_simple_dialogue(player):
	player.is_talking = true
	var ui = dialogue_ui_scene.instantiate()
	ui.player_ref = player
	ui.dialogue_queue = [
		{"name": "公主", "icon": princess_icon, "text": "快去杀死魔王，解除诅咒！"}
	]
	get_tree().root.add_child(ui)
