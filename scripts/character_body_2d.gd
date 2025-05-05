extends CharacterBody2D

# Swipe input variables
var swipe_start := Vector2.ZERO
var swipe_end := Vector2.ZERO
var is_swiping := false
var initial_swipe := false	# Used to track the first meaningful swipe
var original_radius: float	# Stores the unscaled ball radius for resizing


# Signal to notify other scripts of bounce count changes
signal bounce_count_changed
var bounce_count := 0

# Exported physics parameters
@export var swipe_force_multiplier := 10000.0
@export var gravity := 980.0
@export var bounce_factor := 0.8  # 1.0 = perfect bounce, < 1.0 = energy loss

# Called to reset and scale the ball based on current game settings
func initialize():
	bounce_count = 0	# Reset bounce count
	var original_sprite_scale = Vector2(0.299, 0.299)	# Base sprite scale
	$AnimatedSprite2D.modulate = Settings.ball_color	# Apply chosen color
	var corridor_height = get_parent().get_parent().get_collision_height()

	# Always duplicate to ensure unique shape
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	var shape = $CollisionShape2D.shape as CircleShape2D

	# Set original_radius only once
	if original_radius < 0.0:
		original_radius = shape.radius

	# Calculate maximum allowed diameter (within outlet fit constraint)
	var max_ball_diameter = corridor_height / 1.5
	var current_diameter = original_radius * 2
	var max_scale = max_ball_diameter / current_diameter

	# Get user’s desired ball scale
	var s = clamp(Settings.ball_scale, 0.1, max_scale)

	# Apply scale to both sprite and collision shape
	$AnimatedSprite2D.scale = original_sprite_scale * s
	shape.radius = original_radius * s

	swipe_force_multiplier = swipe_force_multiplier / s	# Normalize swipe power
	
	
# Called once when the node is ready
func _ready():
	var shape = $CollisionShape2D.shape as CircleShape2D
	original_radius = shape.radius  # Get the actual radius from the scene
	initialize()
	
# Called when resizing during gameplay (e.g., via pause menu)	
func _reset_size(corridor_height):
	var original_sprite_scale = Vector2(0.299, 0.299)
	corridor_height = get_parent().get_parent().get_collision_height(true)
	
	var shape = $CollisionShape2D.shape as CircleShape2D
	original_radius = shape.radius  # Get the actual radius from the scene
	# Calculate max allowed ball diameter (110% rule)
	var max_ball_diameter = corridor_height / 1.6

	# Compute the current ball diameter
	var current_diameter = original_radius * 2

	# Calculate max allowed scale
	var max_scale = max_ball_diameter / current_diameter
	var s = clamp(Settings.ball_scale, 0.1, max_scale)

	# Apply scale
	$AnimatedSprite2D.scale = original_sprite_scale * s
	shape.radius = original_radius * s
	
	

# Swipe input detection (touch or mouse)
func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		initial_swipe = true
		if event.pressed:
			swipe_start = event.position
			$swipe.play()
			is_swiping = true
		else:
			swipe_end = event.position
			if is_swiping:
				is_swiping = false
				apply_swipe_velocity()

# Calculate and apply swipe movement
func apply_swipe_velocity():
	var swipe_vector = swipe_end - swipe_start
	if swipe_vector.length() > 20:
		velocity = swipe_vector.normalized() * min(swipe_vector.length(), 300) * (swipe_force_multiplier / 1000.0)
		print("Swipe applied:", velocity)

# Called every physics frame
func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta
	
	#Derease speed
	# Apply damping to simulate friction/air resistance
	velocity *= 0.98

	# Check for collision
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collision_position = collision.get_position()
		var collider := collision.get_collider()
		var normal = collision.get_normal()
		# Reflect off the surface
		velocity = velocity.bounce(normal)

		# Apply tangential velocity from rotating surface "level 2" if valid
		if collider.name == "StaticBody2D_level2":
			var center = collider.global_position
			var to_ball = global_position - center
			var angular_velocity = 1.0
			var tangential_velocity = Vector2(-to_ball.y, to_ball.x).normalized() * to_ball.length() * angular_velocity * 0.4
			
			# First push the ball slightly out of the collider
			position += normal * 2
			
			# Then apply the tangential velocity "rotational influence"
			velocity += tangential_velocity * delta
		
		# Calculate impact strength
		var impact_strength = velocity.dot(normal)

		
		if impact_strength > 50:
			var volume = clamp(impact_strength * 0.005, 0, 20)  # Map to decibels
			$AudioStreamPlayer2D.volume_db = volume	
			$AudioStreamPlayer2D.play()

			# Bounce counting and lightning effect
			if initial_swipe:
				bounce_count +=1
				emit_signal("bounce_count_changed", bounce_count) 
				# Show lightning at collision point
				$LightningParticles.global_position = collision_position
				$LightningParticles.emitting = false  # reset if already playing
				$LightningParticles.emitting = true   # trigger lightning burst
		else:
			$AudioStreamPlayer2D.stop()
			
# Manual scaling logic for ball (used outside _ready/init too)		
func apply_custom_scale():
	var original_sprite_scale = Vector2(0.299, 0.299)
	var shape = $CollisionShape2D.shape as CircleShape2D

	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	shape = $CollisionShape2D.shape

	if original_radius < 0.0:
		original_radius = shape.radius

	var s = clamp(Settings.ball_scale, 0.1, 3.0)
	$AnimatedSprite2D.scale = original_sprite_scale * s
	shape.radius = original_radius * s
