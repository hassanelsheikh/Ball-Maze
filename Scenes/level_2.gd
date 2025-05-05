extends Node2D

var rotation_speed = 0.4  # Radians per second (increase for faster rotation)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		get_parent().win_game(false, false)

func _process(delta: float) -> void:
	$Level2Box.rotation += rotation_speed * delta
