const Placement := preload("placement.gd")

var panel : Control
var container_type : String
var children : Array
var split_offset : float
var current_tab : int
var parent

func _init(control : Control) -> void:
	if control is Container:
		children = []
		container_type = control.get_class()
		for child in control.get_children():
			add_child(get_script().new(child))
	else:
		panel = control


func add_child(child) -> void:
	child.parent = self
	children.append(child)


func remove_panels_from_containers():
	if panel:
		if panel.get_parent():
			panel.get_parent().remove_child(panel)
	else:
		for child in children:
			child.remove_panels_from_containers()


func create_control() -> Control:
	if panel:
		return panel
	var container : Container = ClassDB.instance(container_type)
	for child in children:
		container.add_child(child.create_control())
	if container is TabContainer:
		container.current_tab = current_tab
		container.drag_to_rearrange_enabled = true
	elif container is SplitContainer:
		container.connect("dragged", self, "_on_SplitContainer_dragged")
		container.split_offset = split_offset
	return container


func _on_SplitContainer_dragged(offset : int) -> void:
	split_offset = offset


func place_window_ontop(window : Control, placement : Placement) -> void:
	if false:
#	if panel and placement.middle:
		parent.add_child(get_script().new(window))
	else:
		add_child(get_script().new(panel))
		add_child(get_script().new(window))
		if placement.first:
			children.invert()
		if placement.middle:
			container_type = "TabContainer"
		elif placement.horizontal:
			container_type = "HSplitContainer"
		elif placement.vertical:
			container_type = "VSplitContainer"
		if not placement.middle:
			split_offset = panel.rect_size.x / 2
		panel = null


func remove_child(child) -> void:
	children.erase(child)
	if children.size() == 1:
		panel = children.front().panel
		children.front().parent = null
		children.clear()
