extends CharacterBody2D

# Velocidade de movimento
const SPEED = 300.0
const WALK_Y = 397.0

# Estados possíveis do personagem
enum State {IDLE, WALKING, TALKING, PICKING_UP}
var current_state = State.IDLE

# Ponto de destino do clique
var target_position = Vector2.ZERO
var is_moving = false
var walk_callback: Callable = Callable()
var start_animation = "idle"
var start_flip = false

func _ready():
	await get_tree().process_frame
	$Sprite2D.flip_h = start_flip
	$AnimationPlayer.play(start_animation)

func _input(event):
	# Detecta clique do mouse (botão esquerdo)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_pos = get_global_mouse_position()
			
			if click_pos.y < 80 or click_pos.y > 460:
				return
			# Define destino como posição do clique
			var offset = 40
			if click_pos.x > position.x:
				click_pos.x -= offset
			else:
				click_pos.x += offset
				
			target_position = Vector2(
				clamp(click_pos.x, 45, 925),
				WALK_Y
			)
			is_moving = true
			_set_state(State.WALKING)
			

func walk_to(destination: Vector2, callback: Callable = Callable()):
	var offset = 40.0
	if destination.x > position.x:
		destination.x -= offset
	else:
		destination.x += offset
	target_position = Vector2(
		clamp(destination.x, 45, 925),
		WALK_Y
	)
	is_moving = true
	walk_callback = callback
	_set_state(State.WALKING)

func _physics_process(_delta):
	if not is_inside_tree():
		return
	if is_moving:

		var direction = (target_position - position)

		if direction.length() < 5.0:
			is_moving = false
			velocity = Vector2.ZERO
			_set_state(State.IDLE)
			
			if walk_callback.is_valid():
				walk_callback.call()
				walk_callback = Callable()
		else:

			velocity = direction.normalized() * SPEED
			if abs(velocity.x) > abs(velocity.y):
				$Sprite2D.flip_h = velocity.x < 0
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	position.x = clamp(position.x, 45, 925)
	position.y = WALK_Y


func _set_state(new_state: State):
	current_state = new_state
	_update_animation()

func _update_animation():
	match current_state:
		State.IDLE:
			$AnimationPlayer.play("idle")
		State.WALKING:
			# Espelha o sprite dependendo da direção
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x < 0:
					$Sprite2D.flip_h = true
				else:
					$Sprite2D.flip_h = false
			$AnimationPlayer.play("walk")
		State.TALKING:
			$AnimationPlayer.play("talk")
		State.PICKING_UP:
			$AnimationPlayer.play("pickup")
