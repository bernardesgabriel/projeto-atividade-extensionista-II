extends Node

# Estados do jogo
enum GameState {
	INTRO,
	EXPLORING,
	DIALOG,
	TRANSITIONING,
	GAME_OVER
}

var current_state = GameState.INTRO
var dialogs = {}

# Referências aos nós da cena
@onready var player = $"../Player"
@onready var dialog_box = $"../UI/DialogBox"
@onready var hud = $"../UI/HUD"
@onready var npc = $"../NPC"
@onready var notebook = $"../UI/Notebook"

func _ready():
	player.start_animation = "pickup_inicial"
	player.start_flip = true
	player.position = Vector2(630, player.WALK_Y)


	dialogs = dialog_box.load_dialogs()


	player.set_process_input(false)
	

	dialog_box.dialog_finished.connect(_on_dialog_finished)
	dialog_box.dialog_line_shown.connect(_on_dialog_line_shown)

	hud.time_over.connect(_on_time_over)
	hud.notebook_opened.connect(_on_notebook_opened)
	npc.npc_clicked.connect(_on_npc_clicked)

	await get_tree().create_timer(1.0).timeout
	_start_intro()
	
func _on_dialog_line_shown(_speaker: String, index: int, sequence_key: String):

	if sequence_key == "recepcao_conversa":
		if index == 5:  # "quando voce sair... "
			hud.show_timer_animated()
		if index == 8:  # "bloco de notas..."
			GameData.notebook_delivered = true
			hud.show_notebook_animated()
	
func _on_npc_clicked():
	if current_state != GameState.EXPLORING:
		return
	current_state = GameState.DIALOG
	player.set_process_input(false)
	player.walk_to(npc.global_position, _on_player_reached_npc)
	
func _on_player_reached_npc():
	npc.start_talking(player.global_position)
	dialog_box.play_sequence(dialogs, "npc_dicas")
	
func _on_notebook_opened():
	notebook.toggle()

func _start_intro():
	current_state = GameState.DIALOG
	AudioManager.stop_music()
	AudioManager.play_alarm()
	dialog_box.play_sequence(dialogs, "escritorio_alarme")

func _on_dialog_finished():
	match current_state:
		GameState.DIALOG:
			if sequence_index < sequence_order.size():
				
				_next_sequence()
			else:
				current_state = GameState.EXPLORING
				player.set_process_input(true)
				npc.stop_talking()

var sequence_order = [
	"escritorio_alarme",
	"recepcao_conversa"
]
var sequence_index = 0

func _next_sequence():
	sequence_index += 1
	
	if sequence_index < sequence_order.size():
		await get_tree().create_timer(0.5).timeout
		dialog_box.play_sequence(dialogs, sequence_order[sequence_index])
	else:
		_start_exploration()
	if current_state == GameState.EXPLORING:
		npc.stop_talking()

func _start_exploration():
	current_state = GameState.EXPLORING
	# Libera o player para se mover
	player.set_process(true)
	player.set_physics_process(true)
	player.set_process_input(true)
	npc.get_node("AnimationPlayer").play("idle")
	player.get_node("AnimationPlayer").play("idle")
	AudioManager.play_ambient()

func _on_time_over():
	GameData.trigger_game_over(get_tree())

func change_room(room_path: String):
	current_state = GameState.TRANSITIONING
	get_tree().change_scene_to_file(room_path)
	
# IMPLEMENTANDO MUDANÇA DE MAPA
func door_clicked(door_position: Vector2, target_scene: String):
	if current_state != GameState.EXPLORING:
		return
	current_state = GameState.TRANSITIONING
	
	player.walk_to(door_position, func():
		_transition_to(target_scene)
	)

func _transition_to(target_scene: String):
	current_state = GameState.TRANSITIONING
	
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	get_tree().current_scene.add_child(canvas)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.size = Vector2(960, 540)
	canvas.add_child(overlay)
	

	var tween = create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.8)
	tween.tween_callback(func(): 

		_show_transition_message(canvas, overlay, target_scene)
	)

func _show_transition_message(_canvas: CanvasLayer, overlay: ColorRect, target_scene: String):

	var label = Label.new()
	AudioManager.play_mroom()
	label.text = "[ AS COMUNICAÇÕES FORAM ENCERRADAS ]\n[ A PORTA SERÁ TRANCADA... ]"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 24)
	label.modulate = Color.WHITE
	overlay.add_child(label)
	

	await get_tree().create_timer(4.0).timeout
	
	# Iniciar o timer só depois de sair do escritório
	hud.start_timer()
	
	get_tree().change_scene_to_file(target_scene)
