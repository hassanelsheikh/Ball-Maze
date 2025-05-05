extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D":
		# Only trigger win condition and play sound for Level 3
		if get_parent().get_node("level3").visible:
			get_parent().win_game(true, true)  # Calls win_game() in the parent scene (game.gd)
