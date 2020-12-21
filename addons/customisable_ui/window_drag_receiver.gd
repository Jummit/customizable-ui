extends Control

const PlacementUtils := preload("res://addons/customisable_ui/placement_utils.gd")

func _input(event : InputEvent) -> void:
	visible = PlacementUtils.get_window_from_drag_data(
			get_tree(), get_viewport().gui_get_drag_data()) != null


func can_drop_data(position: Vector2, data) -> bool:
	return PlacementUtils.get_window_from_drag_data(
			get_tree(), get_viewport().gui_get_drag_data()) != null


func drop_data(position : Vector2, data) -> void:
	get_tree().call_group("Windows", "place_window_ontop",
			PlacementUtils.get_window_from_drag_data(get_tree(), data))
