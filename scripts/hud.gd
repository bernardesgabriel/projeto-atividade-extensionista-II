extends CanvasLayer

var total_time = 300.0
var time_remaining = 300.0
var timer_active = false

var inventory = []
var max_slots = 2

signal notebook_opened
signal time_over

func _ready():
	$TopBar/NotebookButton.pressed.connect(_on_notebook_pressed)
	$TopBar/NotebookButton.mouse_entered.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND))
	$TopBar/NotebookButton.mouse_exited.connect(func():
		Input.set_default_cursor_shape(Input.CURSOR_ARROW))
	$TopBar/TimerLabel.hide()
	$TopBar/NotebookButton.hide()
	_update_timer_display()
	if GameData.timer_running:
		time_remaining = GameData.time_remaining
		timer_active = true
		$TopBar/TimerLabel.show()
	if GameData.notebook_delivered:
		$TopBar/NotebookButton.show()
	_update_inventory_display()
	
func _update_inventory_display():
	var slots = $BottomBar/InventorySlots.get_children()
	for i in slots.size():
		if i < GameData.inventory.size():
			slots[i].texture = GameData.inventory[i]["texture"]
		else:
			slots[i].texture = null

func start_timer():
	timer_active = true

func _process(delta):
	if not timer_active:
		return
	
	time_remaining -= delta
	GameData.time_remaining = time_remaining
	GameData.timer_running = true
	_update_timer_display()
	
	# Aviso quando falta pouco tempo
	if time_remaining <= 120.0:
		$TopBar/TimerLabel.modulate = Color.RED
	
	if time_remaining <= 0:
		timer_active = false
		time_remaining = 0
		GameData.timer_running = false
		emit_signal("time_over")

func _update_timer_display():
	var minutes = int(time_remaining / 60)
	var seconds = int(time_remaining) % 60
	$TopBar/TimerLabel.text = "TEMPO: %02d:%02d" % [minutes, seconds]

func add_item(item_texture: Texture2D) -> bool:
	if inventory.size() >= max_slots:
		return false
	
	inventory.append(item_texture)
	_update_inventory_display()
	return true

func _on_notebook_pressed():
	emit_signal("notebook_opened")
	
func show_timer_animated():
	$TopBar/TimerLabel.show()
	# Pisca 4 vezes para chamar atenção
	var tween = create_tween()
	tween.tween_property($TopBar/TimerLabel, "modulate:a", 0.0, 0.2)
	tween.tween_property($TopBar/TimerLabel, "modulate:a", 1.0, 0.2)
	tween.tween_property($TopBar/TimerLabel, "modulate:a", 0.0, 0.2)
	tween.tween_property($TopBar/TimerLabel, "modulate:a", 1.0, 0.2)
	tween.tween_property($TopBar/TimerLabel, "modulate:a", 0.0, 0.2)
	tween.tween_property($TopBar/TimerLabel, "modulate:a", 1.0, 0.2)

func show_notebook_animated():
	$TopBar/NotebookButton.show()
	# Pisca o botão do bloco de notas
	var tween = create_tween()
	tween.tween_property($TopBar/NotebookButton, "modulate:a", 0.0, 0.2)
	tween.tween_property($TopBar/NotebookButton, "modulate:a", 1.0, 0.2)
	tween.tween_property($TopBar/NotebookButton, "modulate:a", 0.0, 0.2)
	tween.tween_property($TopBar/NotebookButton, "modulate:a", 1.0, 0.2)
	tween.tween_property($TopBar/NotebookButton, "modulate:a", 0.0, 0.2)
	tween.tween_property($TopBar/NotebookButton, "modulate:a", 1.0, 0.2)
	
func resume_timer():
	timer_active = true
	$TopBar/TimerLabel.show()
	
