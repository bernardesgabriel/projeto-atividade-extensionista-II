extends Node

var dialogs = {}

@onready var player = $"../Player"
@onready var dialog_box = $"../UI/DialogBox"
@onready var hud = $"../UI/HUD"
@onready var door_back = $"../NavigationAreas/DoorCorridor"
@onready var notebook = $"../UI/Notebook"
@onready var background = $"../Background"
@onready var interacao_computador = $"../InteracaoComputador"
@onready var interacao_vazamento = $"../InteracaoVazamento"
@onready var interacao_maquina = $"../InteracaoMaquina"

@onready var lab_fixed = $"../LabFixed"        # sprite do tubo consertado
@onready var machine_full = $"../MachineFull"  # sprite da máquina cheia

@export var cena_puzzle: PackedScene

func _ready():
	lab_fixed.hide()
	machine_full.hide()
	interacao_maquina.hide()
	interacao_computador.hide()
	player.start_animation = "idle"
	player.position = Vector2(80, player.WALK_Y)
	dialogs = dialog_box.load_dialogs()
	dialog_box.dialog_finished.connect(_on_dialog_finished)
	hud.resume_timer()
	door_back.input_pickable = true
	door_back.input_event.connect(_on_door_back_clicked)
	door_back.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	door_back.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
# Interações
	interacao_vazamento.input_pickable = true
	interacao_vazamento.input_event.connect(_on_vazamento_clicked)
	interacao_vazamento.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	interacao_vazamento.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	hud.notebook_opened.connect(_on_notebook_opened)
	interacao_maquina.input_pickable = true
	interacao_maquina.input_event.connect(_on_maquina_clicked)
	interacao_maquina.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	interacao_maquina.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	
	interacao_computador.input_pickable = true
	interacao_computador.input_event.connect(_on_computador_clicked)
	interacao_computador.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	interacao_computador.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	hud.time_over.connect(func():
		GameData.trigger_game_over(get_tree())
	)
	# Diálogo de entrada
	if not GameData.lab_visited:
		GameData.lab_visited = true
		player.set_process_input(false)
		dialog_box.play_sequence(dialogs, "lab_entrance")

	if GameData.lab_leak_fixed:
		lab_fixed.show()
		interacao_vazamento.hide()
		interacao_maquina.show()
	if GameData.lab_tube_inserted:
		machine_full.show()
		interacao_maquina.hide()
		interacao_computador.show()
		
	if GameData.lab_puzzle_complete:
		interacao_computador.hide()
		
func _on_door_back_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		player.walk_to(door_back.global_position, func():
			GameData.transition_to(get_tree(), "res://scenes/rooms/corridor.tscn", "lab")
		)

func _on_vazamento_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialog_box.is_active:
			return
		player.walk_to(interacao_vazamento.global_position, func():
			player.set_process_input(false)
			player.get_node("AnimationPlayer").play("talk")
			if not GameData.has_item("wrench"):
				dialog_box.play_sequence(dialogs, "lab_click_leak")
			else:
				# Conserta o vazamento
				GameData.lab_leak_fixed = true
				GameData.remove_item("wrench")
				hud._update_inventory_display()
				player.get_node("AnimationPlayer").play("pickup")
				await player.get_node("AnimationPlayer").animation_finished
				AudioManager.play_vazfix()
				lab_fixed.show()
				interacao_vazamento.hide()
				interacao_maquina.show()
				dialog_box.play_sequence(dialogs, "lab_click_leak_fixed")
		)

func _on_maquina_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialog_box.is_active:
			return
		player.walk_to(interacao_maquina.global_position, func():
			player.set_process_input(false)
			player.get_node("AnimationPlayer").play("talk")
			if not GameData.has_item("tube_green"):
				dialog_box.play_sequence(dialogs, "lab_click_machine_no_tube")
			else:
				GameData.remove_item("tube_green")
				hud._update_inventory_display()
				GameData.lab_tube_inserted = true
				player.get_node("AnimationPlayer").play("pickup")
				await player.get_node("AnimationPlayer").animation_finished
				AudioManager.play_collect()
				machine_full.show()
				interacao_maquina.hide()
				interacao_computador.show()
				dialog_box.play_sequence(dialogs, "lab_click_machine_ready")
		)

func _on_computador_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dialog_box.is_active:
			return
		player.walk_to(interacao_computador.global_position, func():
			player.set_process_input(false)
			abrir_puzzle()
		)

func door_clicked(door_position: Vector2, target_scene: String):
	player.walk_to(door_position, func():
		GameData.transition_to(get_tree(), target_scene, "lab")
	)

func _on_dialog_finished():
	if GameData.lab_puzzle_complete:
		await get_tree().create_timer(1.0).timeout
		GameData.transition_to(get_tree(), "res://scenes/menu/ending.tscn", "lab")
		return
	player.set_process_input(true)
	player.get_node("AnimationPlayer").play("idle")
	

func abrir_puzzle():
	var novo_puzzle = cena_puzzle.instantiate()
	add_child(novo_puzzle)
	novo_puzzle.puzzle_completed.connect(_on_puzzle_completed)
	get_tree().paused = true
	
func _on_puzzle_completed():
	GameData.lab_puzzle_complete = true
	get_tree().paused = false
	interacao_computador.hide()
	player.set_process_input(false)
	player.get_node("AnimationPlayer").play("talk")
	dialog_box.play_sequence(dialogs, "lab_success")
		
func _on_notebook_opened():
	$"../UI/Notebook".toggle()
