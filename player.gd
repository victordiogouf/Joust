extends CharacterBody2D

signal enemy_defeated
signal defeated

const SPEED = 300.0
const JUMP_VELOCITY = -180.0

var initial_pos: Vector2

func _ready() -> void:
	initial_pos = position
	
func respawn() -> void:
	position = initial_pos
	$Sprite2D.modulate = Color(100, 100, 100)
	$CollisionPolygon2D.disabled = true
	$CollisionPolygon2D.disabled = true
	set_physics_process(false)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 2)
	
	await get_tree().create_timer(2).timeout
	
	$CollisionPolygon2D.disabled = false
	$CollisionPolygon2D.disabled = false
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var size_x = get_viewport_rect().size.x
	if position.x < -30:
		position.x = size_x + 29
	elif position.x > size_x + 30:
		position.x = -29
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * 0.7 * delta

	# Handle jump.
	if Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if direction < 0:
			$Sprite2D.scale.x = -abs($Sprite2D.scale.x)
			$CollisionPolygon2D.scale.x = -abs($CollisionPolygon2D.scale.x)
			$CollisionShape2D.position.x = abs($CollisionShape2D.position.x)
		else:
			$Sprite2D.scale.x = abs($Sprite2D.scale.x)
			$CollisionPolygon2D.scale.x = abs($CollisionPolygon2D.scale.x)
			$CollisionShape2D.position.x = -abs($CollisionShape2D.position.x)
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/5)

	move_and_slide()
	handle_character_collisions()
	

func handle_character_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if collider is CharacterBody2D:
			if collider.position.y > position.y:
				enemy_defeated.emit(collider)
			else:
				defeated.emit(collider)
			break
