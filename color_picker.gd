extends ColorPickerButton

# called when a layout is saved
# can be used to store layout-specific data
func get_layout_data() -> Color:
	return color


# called when a layout is loaded
func _on_layout_changed(meta) -> void:
	color = meta
