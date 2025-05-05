extends Node2D  

# Get references to nodes at runtime
@onready var ball_body = $Ball/CharacterBody2D  # if Ball IS the CharacterBody2D
@onready var win_label = $Win
@onready var timer_label = $Timer
@onready var bounce_label = $Bounces

# Game state variables
var is_game_over := false
var bounce_count := 0  
var START_POS_X = 100
var START_POS_Y = 30


var elapsed_time := 0.0

# Calculates outlet/corridor height for ball resizing
#Get collision shape height
func get_collision_height(level2 = false) -> float:
	var shape = $Sprite2D/WinZone/CollisionShape2D.shape
	if level2:
		shape = $level2/Area2D/CollisionShape2D.shape

	# Determine shape height based on shape type
	if shape is RectangleShape2D:
		return shape.size.y
	elif shape is CapsuleShape2D:
		return shape.height + shape.radius * 2
	elif shape is CircleShape2D:
		return shape.radius * 2
	else:
		printerr("Unsupported shape type for height calculation")
		return 0.0



#Winning function "Triggers when player wins"
func win_game(finish = false, final = false) -> void:
	is_game_over = true
	$WinSound.play()
	win_label.show()
	var score = calculate_score(elapsed_time, bounce_count)
	print(score)
	$Score.show()
	$Score.text = "SCORE: %.0f" % score
	$Ball/CharacterBody2D.initial_swipe = false
	if !finish:
		$Next.show()	# Show button to proceed to next level
	if final:
		$end_music.play()
		


func _ready() -> void:
	# Initial setup: hide all UI
	win_label.hide()
	$Score.hide()
	ball_body.connect("bounce_count_changed", _on_ball_bounce)	# Connect signal to bounce counter
	$Next.hide()
	$level2.hide()
	$level3.hide()

	# Disable level 2 and 3 collision areas at start
	$level2/Level2Box/StaticBody2D_level2/CollisionPolygon2D.disabled = true
	$level2/Level2Box/Area2D/CollisionShape2D.disabled = true
	$level3/Level3Box/StaticBody2D/CollisionPolygon2D.disabled = true
	$level3/Level3Box/Area2D/CollisionShape2D.disabled = true
	
	#Hide pause menu
	$Pause2.hide()
	
	#Check Background Option
	var background = Settings.background
	if background == "Original":
		$LevelBg.show()
		$Space.hide()
		$Sky.hide()
	
	if background == "Space":
		$Space.show()
		$LevelBg.hide()
		$Sky.hide()
		
	if background == "Nature":
		$LevelBg.hide()
		$Space.hide()
		$Sky.show()


	
func _process(delta):
	if is_game_over:
		return
	elapsed_time += delta	# Increase timer
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	timer_label.text = "Time: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	
func calculate_score(time_seconds: float, bounces: int) -> float:
	var time_weight = 0.6  # importance of time (60%)
	var bounce_weight = 0.4  # importance of bounces (40%)

	var normalized_time = clamp(time_seconds / 60.0, 0, 1)  # max 60 sec
	var normalized_bounce = clamp(bounces / 20.0, 0, 1)     # max 20 bounces

	var score = 100.0 * (1.0 - (normalized_time * time_weight + normalized_bounce * bounce_weight))
	return max(score, 0.0)	# Prevent negative scores





func _on_win_zone_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		is_game_over = true
		$WinSound.play()
		win_label.show()
		var score = calculate_score(elapsed_time, bounce_count)
		print(score)
		$Score.show()
		$Score.text = "SCORE: %.0f" % score
		$Next.show()

		
		
func _on_ball_bounce(new_count):
	bounce_count = new_count
	bounce_label.text = "Bounces: %d" % new_count

# Restart current level (via Play Again or Next Level)
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

# Exit to main menu
func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	

func _on_next_pressed() -> void:
	# Reset game state
	is_game_over = false
	bounce_count = 0
	elapsed_time = 0.0
	win_label.hide()
	$Score.hide()
	$Next.hide()
	$Ball/CharacterBody2D.initial_swipe = false

	bounce_label.text = "Bounces: 0"
	timer_label.text = "Time: 00:00"

	# Reset ball to starting position
	ball_body.position = Vector2(START_POS_X, START_POS_Y)
	if ball_body.has_method("set_velocity"):
		# Clear velocity if supported
		ball_body.set_velocity(Vector2.ZERO)
	elif ball_body.has_method("linear_velocity"):
		ball_body.linear_velocity = Vector2.ZERO

	# Enable level2 collisions (if going to level2)
	$level2/Level2Box/StaticBody2D_level2/CollisionPolygon2D.disabled = false
	$level2/Level2Box/Area2D/CollisionShape2D.disabled = false

	# Disable win zone of current level
	$Sprite2D/StaticBody2D/CollisionPolygon2D.disabled = true
	$Sprite2D/WinZone/CollisionShape2D.disabled = true

	# Level management
	if $level1.visible:
		$level1.hide()
		$level2.show()
	elif $level2.visible:
		$level2.hide()
		$level3.show()
		$level2/Level2Box/StaticBody2D_level2/CollisionPolygon2D.disabled = true
		$level2/Level2Box/Area2D/CollisionShape2D.disabled = true
		
		$level3/Level3Box/StaticBody2D/CollisionPolygon2D.disabled = false
		$level3/Level3Box/Area2D/CollisionShape2D.disabled = false
	else:
		print("No more levels")

	$Ball/CharacterBody2D.initialize()	# Reinitialize ball


func _on_pause_pressed() -> void:
	get_tree().paused = true
	$Pause2.show()
	
	
