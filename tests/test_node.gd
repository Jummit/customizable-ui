extends WATTest

const UINode := preload("res://addons/customizable_ui/ui_node.gd")
const Placement := preload("res://addons/customizable_ui/placement.gd")

var root : UINode
var scene : Control

func pre():
	scene = preload("assets/layout.tscn").instance()
	add_child(scene)
	root = UINode.new(scene.get_child(0))


func post():
	scene.queue_free()


func test_creation():
	describe("When loading a tree")
	asserts.is_equal(root.container_type, "VSplitContainer", "Container type is set correctly")
	asserts.is_null(root.panel, "Panel is not set on container nodes")
	asserts.is_equal(root.children.size(), 2, "Children get loaded")


func test_moving():
	describe("When placing a window ontop of another")
	root.children[1].place_window_ontop(scene.get_node("VSplitContainer/HSplitContainer/Window"), Placement.new(0, 1))
	asserts.is_null(root.children[1].panel, "Created container doesn't have panel")
	asserts.is_equal(root.children[1].container_type, "VSplitContainer", "Correct container type is created")
	asserts.is_equal(root.children[1].children.size(), 2, "Container holds windows")


func test_moving_on_parent():
	describe("When placing a window ontop of a parent one")
	root.children[0].children[1].children[0].place_window_ontop(scene.get_node("VSplitContainer/HSplitContainer/Window"), Placement.new(0, 0))
	var node = root.children[0].children[0]
	asserts.is_null(node.panel, "Created container doesn't have panel")
	asserts.is_equal(node.container_type, "TabContainer", "Correct container type is created")
	asserts.is_equal(node.children.size(), 2, "Container holds windows")
