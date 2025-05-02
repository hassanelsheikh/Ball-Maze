extends CharacterBody2D

var swipe_start := Vector2.ZERO
var swipe_end := Vector2.ZERO
var is_swiping := false
var initial_swipe := false
var original_radius: float


signal bounce_count_changed
var bounce_count := 0

@export var swipe_force_multiplier := 10000.0
@export var gravity := 980.0
@export var bounce_factor := 0.8  # 1.0 = perfect bounce, < 1.0 = energy loss


func _ready():
	var original_sprite_scale = Vector2(0.299, 0.299)
	$AnimatedSprite2D.modulate = Settings.ball_color
	var corridor_height = get_parent().get_parent().get_collision_height()
	
	var shape = $CollisionShape2D.shape as CircleShape2D
	original_radius = shape.radius  # Get the actual radius from the scene
	# Calculate max allowed ball diameter (110% rule)
	var max_ball_diameter = corridor_height / 1.3

	# Compute the current ball diameter
	var current_diameter = original_radius * 2

	# Calculate max allowed scale
	var max_scale = max_ball_diameter / current_diameter
	var s = clamp(Settings.ball_scale, 0.1, max_scale)

	# Apply scale
	$AnimatedSprite2D.scale = original_sprite_scale * s
	shape.radius = original_radius * s
	
	#Make the force of ball dynamic based on ball size
	swipe_force_multiplier = swipe_force_multiplier / s
	
	
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
		var collision_position = collision.get_position()
		#Collision effect

		velocity = velocity.bounce(collision.get_normal())
		var normal = collision.get_normal()	
		var impact_strength = velocity.dot(normal)

		
		if impact_strength > 50:
			var volume = clamp(impact_strength * 0.005, 0, 20)  # Map to decibels
			$AudioStreamPlayer2D.volume_db = volume	
			$AudioStreamPlayer2D.play()
			if initial_swipe:
				bounce_count +=1
				emit_signal("bounce_count_changed", bounce_count) 
				# Show lightning at collision point
				$LightningParticles.global_position = collision_position
				$LightningParticles.emitting = false  # reset if already playing
				$LightningParticles.emitting = true   # trigger lightning burst
		else:
			$AudioStreamPlayer2D.stop()
