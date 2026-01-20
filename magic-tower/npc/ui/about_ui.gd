extends CanvasLayer

@onready var close_btn = $Control/Panel/CloseButton
@onready var rich_text_label = $Control/Panel/RichTextLabel

func _ready():
	close_btn.pressed.connect(queue_free)
	rich_text_label.meta_clicked.connect(_on_meta_clicked)

func _on_meta_clicked(meta):
	OS.shell_open(str(meta))

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()
