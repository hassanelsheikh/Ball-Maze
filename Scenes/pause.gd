extends Control
var original_sprite_scale := Vector2(0.299, 0.299)
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_h_slider_2_value_changed(value: float) -> void:
	var s = clamp(value, 0.1, 3.0)
	Settings.ball_scale = s

	# Apply scale to preview ball sprite
	var preview_sprite2 = $PreviewBall2/AnimatedSprite2D
	preview_sprite2.scale = original_sprite_scale * s


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false

	var ball = get_tree().get_root().get_node("Game/Ball/CharacterBody2D")  # Change path as needed
	if ball.has_method("apply_custom_scale"):
		ball.apply_custom_scale()
