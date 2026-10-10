extends CharacterBody2D

signal off_screen_limits

const SPEED = 250.0
const JUMP_VELOCITY = -140.0

enum Sense {
	left,
	right
}

@export var sense: Sense
var time: float = 0

# Variables to control movement randomness
var timer_change_y: float = randf_range(0,8)
var timer_y: float = -1
var fall: bool = false
# end

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	timer_change_y -= delta
	if timer_change_y < 0:
		timer_change_y = INF
		if randf() < 0.5:
			fall = true
			timer_y = randf_range(0.5, 1.2)
		else:
			timer_y = randf_range(1, 2.5)
			fall = false
	
	if timer_y > 0:
		timer_y -= delta
		if not fall:
			velocity.y = JUMP_VELOCITY
	else:
		# Handle jump.
		time += delta
		if time > 0.285:
			velocity.y = JUMP_VELOCITY # jump
			time = 0
		
	match sense:
		Sense.right: 
			velocity.x = SPEED
			$Sprite2D.scale.x = abs($Sprite2D.scale.x)
			$CollisionPolygon2D.scale.x = abs($CollisionPolygon2D.scale.x)
		Sense.left: 
			velocity.x = -SPEED
			$Sprite2D.scale.x = -abs($Sprite2D.scale.x)
			$CollisionPolygon2D.scale.x = -abs($CollisionPolygon2D.scale.x)
	
	move_and_slide()
	
	
	if position.x < -50 || position.x > 50 + get_viewport_rect().size.x:
		off_screen_limits.emit()
