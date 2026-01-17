extends CanvasLayer

signal dialogue_finished

@onready var icon_rect = $Control/Panel/IconBG/Icon
@onready var name_label = $Control/Panel/Name
@onready var text_label = $Control/Panel/Text

var dialogue_queue = []
var current_dialogue = null
var player_ref = null

func _ready():
	process_next()

func _input(event):
	if event.is_action_pressed("ui_accept") or \
	   event.is_action_pressed("ui_up") or \
	   event.is_action_pressed("ui_down") or \
	   event.is_action_pressed("ui_left") or \
	   event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		process_next()

func process_next():
	if dialogue_queue.is_empty():
		finish()
		return
		
	current_dialogue = dialogue_queue.pop_front()
	name_label.text = current_dialogue.name
	text_label.text = current_dialogue.text
	icon_rect.texture = current_dialogue.icon
	
	if current_dialogue.has("name_color"):
		name_label.add_theme_color_override("font_color", current_dialogue.name_color)
	else:
		name_label.add_theme_color_override("font_color", Color.WHITE)

func finish():
	if player_ref:
		player_ref.is_talking = false
	emit_signal("dialogue_finished")
	queue_free()
