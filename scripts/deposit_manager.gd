extends Node

var dialogs = {}

@onready var player = $"../Player"
@onready var dialog_box = $"../UI/DialogBox"
@onready var hud = $"../UI/HUD"
@onready var notebook = $"../UI/Notebook"
@onready var door_back = $"../NavigationAreas/DoorCorridor"
@onready var item_wrench = $"../ItemWrench"
@onready var item_tube = $"../ItemTubeGreenLarge"

@onready var tube_wrong_small = $"../ItemTubeGreenSmall"
@onready var tube_wrong_blue_large = $"../ItemTubeWrongBlueLarge"
@onready var tube_wrong_blue_small = $"../ItemTubeWrongBlueSmall"
@onready var tube_wrong_red_large = $"../ItemTubeWrongRedLarge"
@onready var tube_wrong_red_small = $"../ItemTubeWrongRedSmall"

@onready var tool_hammer = $"../ItemHammer"
@onready var tool_saw = $"../ItemSaw"
@onready var tool_axe = $"../ItemAxe"

@export var wrench_texture: Texture2D
@export var tube_texture: Texture2D

var is_collecting = false

func _ready():
	player.start_animation = "idle"
	player.position = Vector2(80, player.WALK_Y)
	dialogs = dialog_box.load_dialogs()
	dialog_box.dialog_finished.connect(_on_dialog_finished)
	hud.notebook_opened.connect(_on_notebook_opened)
	door_back.input_pickable = true
	door_back.input_event.connect(_on_door_back_clicked)
	door_back.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	door_back.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))

	hud.time_over.connect(func():
		GameData.trigger_game_over(get_tree())
	)
	
	hud.resume_timer()

	# Item chave
	item_wrench.input_pickable = true
	item_wrench.input_event.connect(_on_wrench_clicked)
	item_wrench.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	item_wrench.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))

		# Item tubo
	item_tube.input_pickable = true
	item_tube.input_event.connect(_on_tube_clicked)
	item_tube.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	item_tube.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
		
	if GameData.wrench_ever_collected:
		item_wrench.hide()
	if GameData.tube_ever_collected:
		item_tube.hide()

	_connect_wrong_item(tube_wrong_small, "deposit_wrong_tube_small")
	_connect_wrong_item(tube_wrong_blue_large, "deposit_wrong_tube_color")
	_connect_wrong_item(tube_wrong_blue_small, "deposit_wrong_tube_color")
	_connect_wrong_item(tube_wrong_red_large, "deposit_wrong_tube_color")
	_connect_wrong_item(tube_wrong_red_small, "deposit_wrong_tube_color")

	_connect_wrong_item(tool_hammer, "deposit_wrong_tool_hammer")
	_connect_wrong_item(tool_saw, "deposit_wrong_tool_saw")
	_connect_wrong_item(tool_axe, "deposit_wrong_tool_axe")



func _on_door_back_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialog_box.is_active:
			return
		player.walk_to(door_back.global_position, func():
			GameData.transition_to(get_tree(), "res://scenes/rooms/corridor.tscn", "deposit")
		)

func _on_wrench_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialog_box.is_active or is_collecting:
			return
		if GameData.wrench_ever_collected:
			return
		is_collecting = true
		player.walk_to(item_wrench.global_position, func():
			player.set_process_input(false)
			player.get_node("AnimationPlayer").play("pickup")
			await player.get_node("AnimationPlayer").animation_finished
			AudioManager.play_collect()
			GameData.wrench_ever_collected = true
			GameData.add_item("wrench", wrench_texture)
			item_wrench.hide()
			hud._update_inventory_display()
			player.get_node("AnimationPlayer").play("talk")
			dialog_box.play_sequence(dialogs, "deposit_wrench_collected")
			is_collecting = false
		)

func _on_tube_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialog_box.is_active or is_collecting:
			return
		if GameData.tube_ever_collected:
			return
		is_collecting = true
		player.walk_to(item_tube.global_position, func():
			player.set_process_input(false)
			player.get_node("AnimationPlayer").play("pickup")
			await player.get_node("AnimationPlayer").animation_finished
			AudioManager.play_collect()
			GameData.tube_ever_collected = true
			GameData.add_item("tube_green", tube_texture)
			item_tube.hide()
			hud._update_inventory_display()
			player.get_node("AnimationPlayer").play("talk")
			dialog_box.play_sequence(dialogs, "deposit_tube_collected")
			is_collecting = false
		)

func _connect_wrong_item(area: Area2D, dialog_key: String):
	area.input_pickable = true
	area.input_event.connect(func(_viewport, event, _shape_idx):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if dialog_box.is_active or is_collecting:
				return
			player.walk_to(area.global_position, func():
				player.set_process_input(false)
				player.get_node("AnimationPlayer").play("talk")
				dialog_box.play_sequence(dialogs, dialog_key)
			)
	)
	area.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	area.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))

func door_clicked(door_position: Vector2, target_scene: String):
	player.walk_to(door_position, func():
		GameData.transition_to(get_tree(), target_scene, "deposit")
	)

func _on_dialog_finished():
	player.set_process_input(true)
	player.get_node("AnimationPlayer").play("idle")
	
func _on_notebook_opened():
	$"../UI/Notebook".toggle()
