extends WATTest

const Window := preload("res://addons/customizable_ui/window.gd")
const UINode := preload("res://addons/customizable_ui/ui_node.gd")
const Placement := preload("res://addons/customizable_ui/placement.gd")

var root : UINode
var layout : Control

func pre():
	layout = preload("assets/layout.tscn").instance()
	root = UINode.new(layout.get_child(0))
	add_child(layout)


func post():
	layout.queue_free()


func test_tree_building():
	describe("When building the tree")
	root.remove_panels_from_containers()
	var control := root.create_control()
	asserts.is_true(control is VSplitContainer, "Containers are created")
	asserts.is_equal(control.get_child_count(), 2, "Containers have children")
	asserts.is_true(control.get_child(0) is HSplitContainer, "Sub-Containers are created")
	asserts.is_class_instance(control.get_child(1), Window, "Windows are created")


func test_tree_destructing():
	describe("When cleaning up tree")
	root.remove_panels_from_containers()
	asserts.is_false(layout.get_node("VSplitContainer").has_node("Window"), "Windows get removed from tree")
	asserts.is_false(layout.get_node("VSplitContainer/HSplitContainer").has_node("Window"), "Windows get removed from tree")
