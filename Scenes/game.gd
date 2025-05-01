extends Node2D  # Make sure this matches your root node

@onready var ball_body = $Ball/CharacterBody2D  # if Ball IS the CharacterBody2D
@onready var win_label = $Win
@onready var timer_label = $Timer
@onready var bounce_label = $Bounces
var is_game_over := false

var win:= false

var elapsed_time := 0.0

func _ready() -> void:
	win_label.hide()
	ball_body.connect("bounce_count_changed", _on_ball_bounce)

	
func _process(delta):
	if is_game_over:
		return
	elapsed_time += delta
	var minutes = int(elapsed_time) / 60
	var seconds = int(elapsed_time) % 60
	timer_label.text = "Time: " + str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)

func _on_win_zone_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		is_game_over = true
		win_label.show()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
		
		
func _on_ball_bounce(new_count):
	bounce_label.text = "Bounces: %d" % new_count
