extends Control

"""
A `Control` that is used for dropping windows anywhere and preview rendering

Shows itself if a window is being dragged. If the window is dropped, tries to
place the window on all other windows until it is successfull.
"""

# warning-ignore:unused_class_variable
export var preview : StyleBox = preload("drop_preview.stylebox")
export var root_control := NodePath("../Root")

const UINode := preload("ui_node.gd")
const Placement := preload("placement.gd")

var root : UINode

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		root = UINode.new(get_node(root_control).get_child(0))


func get_hovered_node(node := root) -> UINode:
	if node.panel:
		if node.panel.is_inside_tree() and\
				node.panel.get_global_rect().has_point(\
				get_global_mouse_position()):
			return node
	else:
		for child in node.children:
			var hovered = get_hovered_node(child)
			if hovered:
				return hovered
	return null


func get_node_from_control(control : Control, node := root) -> UINode:
	if node.children:
		for child in node.children:
			var node_from_control = get_node_from_control(control, child)
			if node_from_control:
				return node_from_control
	elif node.panel == control:
		return node
	return null


func get_placement(node : UINode) -> Placement:
	var mouse := node.panel.get_local_mouse_position()
	var third_size := node.panel.rect_size / 3.0
	if not Rect2(Vector2(), node.panel.rect_size).has_point(mouse):
		return null
	if mouse.x < third_size.x:
		return Placement.new(-1, 0)
	elif mouse.x > third_size.x * 2:
		return Placement.new(1, 0)
	elif mouse.y < third_size.y:
		return Placement.new(0, -1)
	elif mouse.y > third_size.y * 2:
		return Placement.new(0, 1)
	else:
		return Placement.new(0, 0)


func _input(_event : InputEvent) -> void:
	visible = get_window_from_drag_data() and get_hovered_node()
	update()


func can_drop_data(_position: Vector2, data) -> bool:
	var hovered_node := get_hovered_node()
	var panel : Control = get_window_from_drag_data()
	var node := get_node_from_control(panel)
	return panel and panel != hovered_node.panel


func drop_data(_position : Vector2, data) -> void:
	var hovered_node := get_hovered_node()
	var panel := get_window_from_drag_data()
	var node := get_node_from_control(panel)
	node.parent.remove_child(node)
	if not hovered_node.parent:
		hovered_node = node.parent
	hovered_node.place_window_ontop(panel, get_placement(hovered_node))
	
	root.remove_panels_from_containers()
	get_node(root_control).get_child(0).queue_free()
	yield(get_tree(), "idle_frame")
	var root_panel := root.create_control()
	get_node(root_control).add_child(root_panel)
	root_panel.rect_position = Vector2.ZERO
	root_panel.anchor_right = 1
	root_panel.anchor_bottom = 1
	root_panel.margin_right = 0
	root_panel.margin_bottom = 0


func _draw() -> void:
	var hovered := get_hovered_node()
	if not can_drop_data(Vector2(), get_viewport().gui_get_drag_data()):
		return
	var placement := get_placement(hovered)
	var third_size := hovered.panel.rect_size / 3.0
	var rect := Rect2(Vector2(), third_size)
	if placement.horizontal:
		rect.size.y = hovered.panel.rect_size.y
	elif placement.vertical:
		rect.size.x = hovered.panel.rect_size.x
	if placement.right:
		rect.position.x = third_size.x * 2
	elif placement.bottom:
		rect.position.y = third_size.y * 2
	if placement.middle:
		rect.position = third_size
	rect.position += hovered.panel.rect_global_position
	preview.draw(get_canvas_item(), rect)


func get_window_from_drag_data() -> Panel:
	var data = get_viewport().gui_get_drag_data()
	if data is Dictionary and "type" in data:
		match data.type:
			"window":
				return data.window
			"tabc_element":
				return get_tree().root.get_node(data.from_path).\
					get_child(data.tabc_element) as Panel
	return null
