extends Node2D



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
