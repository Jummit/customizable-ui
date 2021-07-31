extends "res://addons/customizable_ui/window.gd"

func get_layout_data():
	return $Content.text


func load_layout_data(data) -> void:
	$Content.text = data
