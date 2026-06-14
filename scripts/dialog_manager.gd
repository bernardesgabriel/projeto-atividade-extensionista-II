extends CanvasLayer

const LETTER_SPEED = 0.04

var is_active = false
var is_typing = false
var current_text = ""
var char_index = 0
var current_sequence = []
var current_sequence_key = ""
var current_index = 0

var typing_timer: Timer

signal dialog_finished
signal dialog_line_shown(speaker: String, index: int, sequence_key: String)

func _ready():
	typing_timer = Timer.new()
	typing_timer.wait_time = LETTER_SPEED
	typing_timer.timeout.connect(_on_typing_timer)
	add_child(typing_timer)
	hide()

func load_dialogs() -> Dictionary:
	var file = FileAccess.open("res://data/dialogs.json", FileAccess.READ)
	if file:
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()
		if result == OK:
			return json.get_data()
	return {}


func play_sequence(dialogs: Dictionary, sequence_key: String):
	if dialogs.has(sequence_key):
		current_sequence = dialogs[sequence_key]
		current_sequence_key = sequence_key
		current_index = 0
		_show_current_line()
	else:
		print("Sequencia nao encontrada: " + sequence_key)

func _show_current_line():
	if current_index < current_sequence.size():
		var line = current_sequence[current_index]
		_start_dialog(line["speaker"], line["text"])
		emit_signal("dialog_line_shown", line["speaker"], current_index, current_sequence_key)
	else:
		_finish_sequence()

func _start_dialog(speaker_name: String, text: String):
	is_active = true
	is_typing = true
	current_text = text
	char_index = 0
	show()
	
	if has_node("Panel/NameLabel"):
		$Panel/NameLabel.text = speaker_name
	if has_node("Panel/DialogText"):
		$Panel/DialogText.text = ""
	if has_node("Panel/ContinueIcon"):
		$Panel/ContinueIcon.hide()
	
	typing_timer.start()

func _on_typing_timer():
	if char_index < current_text.length():
		char_index += 1
		if has_node("Panel/DialogText"):
			$Panel/DialogText.text = current_text.substr(0, char_index)
	else:
		is_typing = false
		typing_timer.stop()
		if has_node("Panel/ContinueIcon"):
			$Panel/ContinueIcon.show()

func _input(event):
	if not is_active:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			if is_typing:
				typing_timer.stop()
				current_text = current_sequence[current_index]["text"]
				if has_node("Panel/DialogText"):
					$Panel/DialogText.text = current_text
				is_typing = false
				if has_node("Panel/ContinueIcon"):
					$Panel/ContinueIcon.show()
			else:
				current_index += 1
				_show_current_line()

func _finish_sequence():
	is_active = false
	hide()
	emit_signal("dialog_finished")
