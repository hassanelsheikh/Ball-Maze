extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		get_parent().win_game(true)
		$AudioStreamPlayer2D.play()
