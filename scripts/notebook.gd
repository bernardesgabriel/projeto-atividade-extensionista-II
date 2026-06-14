extends CanvasLayer

var is_open = false

@onready var player = get_tree().get_root().find_child("Player", true, false)

func _ready():
	hide()
	$Panel/CloseButton.pressed.connect(close_notebook)

func toggle():
	if is_open:
		close_notebook()
	else:
		open_notebook()

func open_notebook():
	is_open = true
	show()
	$Panel/TextEdit.text = GameData.notebook_content
	$Panel/TextEdit.grab_focus()
	if player:
		player.set_process_input(false)

func close_notebook():
	is_open = false
	GameData.notebook_content = $Panel/TextEdit.text
	hide()
	if player:
		player.set_process_input(true)

func get_notes() -> String:
	return $Panel/TextEdit.text
	
func _input(event):
	if not is_open:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close_notebook()
