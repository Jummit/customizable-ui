"""
Utility to save and load layouts as json files
"""

static func save_layout(root : Container, layout_file : String) -> void:
	var layout := {
		windows = _store_layout(root),
		popped_out = []
	}
	
	for window in root.get_tree().get_nodes_in_group("Windows"):
		var parent : Control = window.get_parent()
		if parent is WindowDialog:
			var data := {
				x = parent.rect_position.x,
				y = parent.rect_position.y,
				width = parent.rect_size.x,
				height = parent.rect_size.y,
				name = window.name,
			}
			var layout_data = window.get_data()
			if layout_data:
				data.data = var2str(layout_data)
			layout.popped_out.append(data)
	
	var file := File.new()
	file.open(layout_file, File.WRITE)
	file.store_string(to_json(layout))
	file.close()


static func load_layout(root : Node, layout_file : String) -> void:
	var file := File.new()
	file.open(layout_file, File.READ)
	var layout : Dictionary = str2var(file.get_as_text())
	file.close()
	
	var windows := {}
	for window in root.get_tree().get_nodes_in_group("Windows"):
		if window.get_parent() is WindowDialog:
			window.get_parent().queue_free()
		window.get_parent().remove_child(window)
		windows[window.name] = window
	
	for popped_out in layout.popped_out:
		var panel : Panel = windows[popped_out.name]
		var window_dialog : WindowDialog = panel.put_in_window()
		window_dialog.rect_position = Vector2(popped_out.x, popped_out.y)
		window_dialog.rect_size = Vector2(popped_out.width, popped_out.height)
		var data
		if "data" in popped_out:
			data = str2var(popped_out.data)
		panel.emit_signal("layout_changed", data)
	
	_remove_containers(root)
	_load_individual_layout(root, layout.windows, windows)


static func _store_layout(root : Container) -> Dictionary:
	var layout := {
		type = root.get_class(),
		children = []
	}
	if root is SplitContainer and root.split_offset:
		layout.split = root.split_offset
	
	for node in root.get_children():
		if node is Panel:
			var layout_data := {
				name = node.name,
			}
			if not node.visible:
				layout_data.visible = false
			var data = node.get_data()
			if data:
				layout_data.data = var2str(data)
			layout.children.append(layout_data)
		else:
			layout.children.append(_store_layout(node))
	
	return layout


static func _remove_containers(root : Node) -> void:
	for child in root.get_children():
		if child is Container:
			root.remove_child(child)
			_remove_containers(child)


static func _load_individual_layout(root : Node, layout : Dictionary,
		windows : Dictionary) -> void:
	var container : Container = ClassDB.instance(layout.type)
	container.anchor_right = 1
	container.anchor_bottom = 1
	for window in layout.children:
		if "name" in window:
			var panel : Panel = windows[window.name]
			container.add_child(panel)
			panel.visible = true if not "visible" in window else window.visible
			var data
			if "data" in window:
				data = str2var(window.data)
			panel.emit_signal("layout_changed", data)
		else:
			_load_individual_layout(container, window, windows)
	root.add_child(container)
	if container is SplitContainer and "split" in layout:
		container.split_offset = layout.split
	if container is TabContainer:
		container.drag_to_rearrange_enabled = true
