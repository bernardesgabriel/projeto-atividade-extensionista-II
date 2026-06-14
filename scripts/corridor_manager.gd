extends Node

var dialogs = {}

@onready var player = $"../Player"
@onready var dialog_box = $"../UI/DialogBox"
@onready var hud = $"../UI/HUD"
@onready var notebook = $"../UI/Notebook"
@onready var door_main = $"../NavigationAreas/DoorMain"
@onready var door_deposit = $"../NavigationAreas/DoorDeposit"
@onready var door_lab = $"../NavigationAreas/DoorLab"
@onready var door_exit = $"../NavigationAreas/DoorExit"

func _ready():
	player.start_animation = "idle"
	match GameData.last_room:
		"main_room":
			player.position = Vector2(80, player.WALK_Y)
		"deposit":
			player.position = Vector2(350, player.WALK_Y)
		"lab":
			player.position = Vector2(650, player.WALK_Y)
			
	dialogs = dialog_box.load_dialogs()
	dialog_box.dialog_finished.connect(_on_dialog_finished)
	hud.notebook_opened.connect(_on_notebook_opened)
	
	door_deposit.input_event.connect(_on_door_deposit_clicked)
	door_lab.input_event.connect(_on_door_lab_clicked)
	door_exit.input_pickable = true
	door_exit.input_event.connect(_on_door_exit_clicked)
	door_exit.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	door_exit.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	
	door_main.input_pickable = true
	door_main.input_event.connect(_on_door_main_clicked)
	door_main.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	door_main.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))

	door_deposit.mouse_entered.connect(func(): 
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	door_deposit.mouse_exited.connect(func(): 
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	door_lab.mouse_entered.connect(func(): 
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	door_lab.mouse_exited.connect(func(): 
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	hud.time_over.connect(func():
		GameData.trigger_game_over(get_tree())
	)
	hud.resume_timer()

func _on_door_deposit_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		player.walk_to(door_deposit.global_position, func():
			GameData.transition_to(get_tree(), "res://scenes/rooms/deposit.tscn", "corridor")
		)

func _on_door_lab_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		player.walk_to(door_lab.global_position, func():
			GameData.transition_to(get_tree(), "res://scenes/rooms/lab.tscn", "corridor")
		)

func _on_door_exit_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		player.walk_to(door_exit.global_position, func():
			player.set_process_input(false)
			player.get_node("AnimationPlayer").play("talk")
			dialog_box.play_sequence(dialogs, "corridor_exit_blocked")
		)

func _on_door_main_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		player.walk_to(door_main.global_position, func():
			player.set_process_input(false)
			player.get_node("AnimationPlayer").play("talk")
			dialog_box.play_sequence(dialogs, "corridor_main_blocked")
		)


func door_clicked(door_position: Vector2, target_scene: String):
	player.walk_to(door_position, func():
		GameData.transition_to(get_tree(), target_scene, "corridor")
	)

func _on_dialog_finished():
	player.set_process_input(true)
	player.get_node("AnimationPlayer").play("idle")
	
func _on_notebook_opened():
	$"../UI/Notebook".toggle()
	
