extends Area2D

@export var target_scene: String = ""
@export var door_sound: AudioStream
var audio_player: AudioStreamPlayer

func _ready():
	input_pickable = true
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	if door_sound:
		audio_player.stream = door_sound


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_door_clicked()

func _on_door_clicked():
	var game_manager = get_tree().get_root().find_child("GameManager", true, false)
	if game_manager:
		if audio_player and door_sound:
			audio_player.play()
		game_manager.door_clicked(global_position, target_scene)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
