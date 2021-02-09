extends Control

# LayoutUtils contains utilities to save and load layouts
var LayoutUtils = preload("res://addons/customizable_ui/layout_utils.gd")

onready var root : Control = $Root
onready var layout_name_edit : LineEdit = $Root/HSplitContainer/MainWindow/HBoxContainer/LayoutNameEdit

func _on_SaveButton_pressed() -> void:
	# save_layout takes the root container. Because this changes when layouts
	# are loaded, `get_child` is used to get the first container.
	LayoutUtils.save_layout(root.get_child(0),
			"res://%s.json" % layout_name_edit.text)


func _on_LoadButton_pressed() -> void:
	# load_layout takes the root control
	LayoutUtils.load_layout(root, "res://%s.json" % layout_name_edit.text)
