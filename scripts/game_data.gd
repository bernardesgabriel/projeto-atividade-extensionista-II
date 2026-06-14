extends Node

# Inventário persiste entre cenas
var inventory = []
var max_slots = 5

# Estado global dos puzzles
var deposit_tool_collected = false
var deposit_tube_collected = false
var lab_leak_fixed = false
var lab_puzzle_complete = false
var notebook_collected = true
var timer_running = false
var time_remaining = 300.0
var last_room = ""
var transition_sound: AudioStream =  null
var lab_tube_inserted = false
var lab_visited = false
var wrench_ever_collected = false
var tube_ever_collected = false
var notebook_delivered = false
var notebook_content = ""

func add_item(item_id: String, item_texture: Texture2D) -> bool:
	if inventory.size() >= max_slots:
		return false
	inventory.append({
		"id": item_id,
		"texture": item_texture
	})
	return true

func has_item(item_id: String) -> bool:
	for item in inventory:
		if item["id"] == item_id:
			return true
	return false

func remove_item(item_id: String):
	for i in inventory.size():
		if inventory[i]["id"] == item_id:
			inventory.remove_at(i)
			return
			
func transition_to(tree: SceneTree, target_scene: String, from_room: String):
	last_room = from_room
	if not target_scene.contains("ending"):
		AudioManager.play_door()

	var canvas = CanvasLayer.new()
	canvas.layer = 10
	tree.current_scene.add_child(canvas)

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.size = Vector2(960, 540)
	canvas.add_child(overlay)

	if transition_sound:
		var audio = AudioStreamPlayer.new()
		audio.stream = transition_sound
		canvas.add_child(audio)
		audio.play()

	var tween = tree.create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.5)
	tween.tween_callback(func():
		tree.change_scene_to_file(target_scene)
	)

func _ready():

	var cursor_normal = load("res://assets/ui/cursor_normal.png")
	var cursor_hand = load("res://assets/ui/cursor_hand.png")
	if cursor_normal:
		Input.set_custom_mouse_cursor(cursor_normal, Input.CURSOR_ARROW)
	if cursor_hand:
		Input.set_custom_mouse_cursor(cursor_hand, Input.CURSOR_POINTING_HAND)
		
func trigger_game_over(tree: SceneTree):
	timer_running = false
	transition_to(tree, "res://scenes/menu/gameover.tscn", "gameover")
		
