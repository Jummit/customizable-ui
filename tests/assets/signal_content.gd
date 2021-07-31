extends Label

func get_layout_data():
	return text


func _on_Window_layout_changed(meta) -> void:
	text = meta
