extends Node2D

const INTRO_TEXT = "Você é um pesquisador da Neurocore, uma corporação de pesquisa em energia limpa.\n\nEra um dia normal de trabalho até que..."
const LETTER_SPEED = 0.04

var char_index = 0
var typing_timer: Timer
var finished_typing = false

func _ready():
	$SkipLabel.hide()
	$IntroText.text = ""
	
	typing_timer = Timer.new()
	typing_timer.wait_time = LETTER_SPEED
	typing_timer.timeout.connect(_on_typing_timer)
	add_child(typing_timer)
	typing_timer.start()

func _on_typing_timer():
	if char_index < INTRO_TEXT.length():
		char_index += 1
		$IntroText.text = INTRO_TEXT.substr(0, char_index)
	else:
		typing_timer.stop()
		finished_typing = true
		$SkipLabel.show()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if not finished_typing:

			typing_timer.stop()
			$IntroText.text = INTRO_TEXT
			finished_typing = true
			$SkipLabel.show()
		else:

			get_tree().change_scene_to_file("res://scenes/rooms/main_room.tscn")
