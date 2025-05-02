extends Control

var ball_scale:= 1.0
var original_sprite_scale := Vector2(0.299, 0.299)
var ball_color := Color(1, 1, 1)
var background:= "Original"



func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	var s = clamp(value, 0.1, 3.0)
	Settings.ball_scale = s

	# Apply scale to preview ball sprite
	var preview_sprite = $PreviewBall/AnimatedSprite2D
	preview_sprite.scale = original_sprite_scale * s


func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		Settings.ball_color =  Color(1, 1, 1)
		$PreviewBall/AnimatedSprite2D.modulate = Settings.ball_color  # White (default)
	elif index == 1:
		Settings.ball_color = Color(1, 0, 0)
		$PreviewBall/AnimatedSprite2D.modulate = Settings.ball_color  # Red
	elif index == 2:
		Settings.ball_color = Color(0, 1, 0)
		$PreviewBall/AnimatedSprite2D.modulate = Settings.ball_color  # Green

	


func _on_option_button_2_item_selected(index: int) -> void:
	if index == 0:
		Settings.background = "Original"
	elif index == 1:
		Settings.background = "Space"
	elif index == 2:
		Settings.background = "Nature"
