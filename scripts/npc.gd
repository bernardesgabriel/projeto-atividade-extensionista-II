extends Node2D

var can_interact = true

signal npc_clicked

func _ready():
	$ClickArea.input_pickable = true
	$ClickArea.input_event.connect(_on_click_area_input)
	# Muda o cursor ao passar por cima
	$ClickArea.mouse_entered.connect(_on_mouse_entered)
	$ClickArea.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_click_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if can_interact:
				emit_signal("npc_clicked")

func face_right():
	$Sprite2D.flip_h = false

func face_left():
	$Sprite2D.flip_h = true

func start_talking(player_position: Vector2):
	if player_position.x < global_position.x:
		face_left()
	else:
		face_right()
	$AnimationPlayer.play("talk")

func stop_talking():
	face_left()
	$AnimationPlayer.play("idle")
	
