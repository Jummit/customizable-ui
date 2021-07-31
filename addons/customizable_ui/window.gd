extends Panel

"""
A panel which can be repositioned by dragging the title above other windows

It draws the preview if a windew is being dragged above it.
It is holds the logic for rearranging the node structure after a window has
been repositioned.

Windows can be popped out by pressing a button which makes them floating windows.
"""

# warning-ignore:unused_signal
signal layout_changed(meta)

onready var title_label : Label = $Title
onready var pop_in_out_button : Button = $PopInOutButton

# used for storing/restoring layouts
# warning-ignore:unused_class_variable
onready var original_path := get_path()

var content : Node

export var title : String setget set_title

func _ready() -> void:
	title_label.set_drag_forwarding(self)
	if title:
		return
	for letter in name:
		if letter.capitalize() == letter:
			title += " "
		title += letter
	title = title.replace("Window", "").substr(1)
	set_title(title)
	if get_child_count() > 2:
		content = get_child(2)
	if get_signal_connection_list("layout_changed").size():
		push_warning("Using the layout_changed signal is deprecated, provide a load_layout_data method instead.")


func _notification(what : int) -> void:
	match what:
		NOTIFICATION_PARENTED:
			if not title_label:
				yield(self, "ready")
			if get_parent() is TabContainer:
				(get_parent() as TabContainer).set_tab_title(get_index(), title)
			if get_parent() is TabContainer or get_parent() is WindowDialog:
				title_label.hide()
			else:
				title_label.show()
		NOTIFICATION_VISIBILITY_CHANGED:
			# apply visibilty to dialog
			if get_parent() is WindowDialog:
				(get_parent() as CanvasItem).visible = visible


func get_layout_data():
	if content and content.has_method("get_layout_data"):
		return content.get_layout_data()


func load_layout_data(data) -> void:
	if content and content.has_method("load_layout_data"):
			content.load_layout_data(data)


func _on_PopInOutButton_pressed():
	if get_parent() is WindowDialog:
		pop_in()
	else:
		pop_out()


func set_title(to : String) -> void:
	if not to:
		# Avoid resetting the title when the setter is called while loading the
		# scene because `title` is exported.
		return
	if not is_inside_tree():
		yield(self, "ready")
	title = to
	title_label.text = title


func get_drag_data_fw(_position : Vector2, _control : Container):
	return {
		type = "window",
		window = self,
	}


func put_in_window() -> WindowDialog:
	var window := WindowDialog.new()
	window.window_title = title
	# don't use `popup_centered`, as it makes the popup modal
	# see `Control.show_modal`
	window.get_close_button().hide()
	window.resizable = true
	# move the window down because the title bar is rendered above
	window.rect_position = get_rect().position + Vector2(0, 20)
	window.rect_size = rect_size
	# `WindowDialog` doesn't use child minimum size
	window.rect_min_size = rect_min_size
	window.add_child(self)
	# TODO: don't use tree.
	get_tree().root.add_child(window)
	window.visible = visible
	pop_in_out_button.text = "v"
	pop_in_out_button.hint_tooltip = "Pop window in."
	return window


func pop_in() -> void:
	get_tree().call_group("Windows", "place_window_ontop", self)
	pop_in_out_button.text = "^"
	pop_in_out_button.hint_tooltip = "Pop window out."


func pop_out() -> void:
	# TODO: remove from node tree.
	put_in_window()
