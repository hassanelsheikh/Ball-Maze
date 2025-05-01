extends CharacterBody2D

var swipe_start := Vector2.ZERO
var swipe_end := Vector2.ZERO
var is_swiping := false

@export var swipe_force_multiplier := 10000.0
@export var gravity := 980.0
@export var bounce_factor := 0.8  # 1.0 = perfect bounce, < 1.0 = energy loss

func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			swipe_start = event.position
			is_swiping = true
		else:
			swipe_end = event.position
			if is_swiping:
				is_swiping = false
				apply_swipe_velocity()

func apply_swipe_velocity():
	var swipe_vector = swipe_end - swipe_start
	if swipe_vector.length() > 20:
		velocity = swipe_vector.normalized() * min(swipe_vector.length(), 300) * (swipe_force_multiplier / 1000.0)
		print("Swipe applied:", velocity)

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	
	#Derease speed
	# Apply damping to simulate friction/air resistance
	velocity *= 0.98
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
