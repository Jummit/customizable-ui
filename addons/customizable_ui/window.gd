tool
extends Panel

export var title := "" setget set_title
onready var root : Control = get_tree().root.find_node(
		"WindowDragReceiver", true, false).get_parent()

const PlacementUtils := preload("placement_utils.gd")

func _ready() -> void:
	$Title.set_drag_forwarding(self)


func _input(event : InputEvent):
	if event is InputEventMouse:
		update()


func _notification(what : int) -> void:
	if what == NOTIFICATION_PARENTED:
		if get_parent() is TabContainer:
			get_parent().set_tab_title(get_index(), title)
		if get_parent() is TabContainer or get_parent() is WindowDialog:
			$Title.hide()
		else:
			$Title.show()


func _draw() -> void:
	var placement := can_place(
			PlacementUtils.get_window_from_drag_data(
			get_tree(), get_viewport().gui_get_drag_data()))
	if not placement:
		return
	var third_size := rect_size / 3.0
	var rect := Rect2(Vector2.ZERO, third_size)
	if placement.horizontal:
		rect.size.y = rect_size.y
	elif placement.vertical:
		rect.size.x = rect_size.x
	if placement.right:
		rect.position.x = third_size.x * 2
	elif placement.bottom:
		rect.position.y = third_size.y * 2
	if placement.middle:
		rect.position = third_size
	draw_rect(rect, Color.lightblue, false, 3)


func place_window_ontop(window : Panel) -> void:
	var placement := can_place(window)
	if not placement:
		return
	
	if get_parent() is TabContainer:
		if placement.middle:
			place_window_into_tabs(window, placement)
		else:
			place_window_on_tabs(window, placement)
	elif window.get_parent() == get_parent():
		place_window_with_same_parent(window, placement)
	else:
		place_window_normal(window, placement)

# container
# ┣ window
# ┗ self
#     ↓
# new_container
# ┣ window
# ┗ self
func place_window_with_same_parent(window : Panel,
		placement : PlacementUtils.WindowPlacement) -> void:
	get_parent().replace_by(placement.get_container(window))

# container
# ┣ other_window
# ┗ self
#      ↓
# container
# ┣ other_window
# ┗ new_container
#   ┣ self
#   ┗ window
func place_window_normal(window : Panel,
		placement : PlacementUtils.WindowPlacement) -> void:
	remove_from_container(window)
	
	var parent := get_parent()
	parent.remove_child(self)
	
	var new_container := placement.get_container(window)
	new_container.add_child(self)
	new_container.add_child(window)
	parent.add_child(new_container)
	parent.move_child(new_container, 0)
	update_size(parent)

# tab_container
# ┣ self
# ┗ other_window
#     ↓
# tab_container
# ┣ self
# ┣ other_window
# ┗ window
func place_window_into_tabs(window : Panel,
		placement : PlacementUtils.WindowPlacement) -> void:
	remove_from_container(window)
	get_parent().add_child(window)

# tab_container
# ┣ other_window
# ┗ self
#    ↓
# new_container
# ┣ tab_container
# ┃ ┣ other_window
# ┃ ┗ self
# ┗ window
func place_window_on_tabs(window : Panel,
		placement : PlacementUtils.WindowPlacement) -> void:
	remove_from_container(window)
	
	var parent_container := get_parent().get_parent()
	var parent := get_parent()
	parent_container.remove_child(parent)
	
	var new_container := placement.get_container(window)
	new_container.add_child(window)
	new_container.add_child(parent)
	
	parent_container.add_child(new_container)
	parent_container.move_child(new_container, 0)
	update_size(new_container)

# container
# ┣ window
# ┗ other_window
#      ↓
# other_window

# container
# ┣ window
# ┣ other_window
# ┗ another_window
#      ↓
# container
# ┣ other_window
# ┗ another_window
func remove_from_container(window : Panel) -> void:
	var parent := window.get_parent()
	parent.remove_child(window)
	window.show()
	if parent is WindowDialog:
		parent.free()
	elif parent.get_child_count() <= 1:
		var other_window = parent.get_child(0)
		parent.remove_child(other_window)
		other_window.show()
		parent.get_parent().add_child(other_window)
		parent.get_parent().move_child(other_window, 0)
		parent.free()


func update_size(container : Control) -> void:
	container.rect_position = Vector2.ZERO
	container.anchor_right = 1
	container.anchor_bottom = 1
	container.margin_right = 0
	container.margin_bottom = 0


func can_place(window : Panel) -> PlacementUtils.WindowPlacement:
	if not window or (not visible or window == self and\
			not get_parent() is TabContainer):
		return null
	var placement := PlacementUtils.get_drop_placement(self)
	if placement and placement.middle and get_parent() is TabContainer:
		return null
	return placement


func pop_out() -> void:
	var window := WindowDialog.new()
	window.window_title = title
	# don't use `popup_centered`, as it makes the popup modal
	# see `Control.show_modal`
	window.get_close_button().hide()
	window.resizable = true
	# move the window down because the title bar is rendered above
	window.rect_position = get_global_rect().position + Vector2(0, 20)
	window.rect_size = rect_size
	
	remove_from_container(self)
	window.add_child(self)
	root.add_child(window)
	window.show()
	update_size(self)
	
	$PopInOutButton.text = "v"


func pop_in() -> void:
	get_tree().call_group("Windows", "place_window_ontop", self)
	$PopInOutButton.text = "^"


func set_title(to) -> void:
	title = to
	$Title.text = to
	if get_parent() is TabContainer:
		get_parent().set_tab_title(get_index(), title)


func get_drag_data_fw(position : Vector2, _control : Container):
	return {
		type = "window",
		window = self,
	}


func _on_PopInOutButton_pressed():
	if get_parent() is WindowDialog:
		pop_in()
	else:
		pop_out()
