extends WATTest

const LayoutUtils := preload("res://addons/customizable_ui/layout_utils.gd")
const Placement := preload("res://addons/customizable_ui/placement.gd")

var scene : Control
var labels : Array

func pre():
	scene = preload("assets/layout.tscn").instance()
	add_child(scene)
	labels = [
		scene.get_node("VSplitContainer/HSplitContainer/TabContainer/Window1/Content"),
		scene.get_node("VSplitContainer/HSplitContainer/TabContainer/Window2/Content"),
		scene.get_node("VSplitContainer/HSplitContainer/TabContainer/Window3/Content"),
	]


func post():
	scene.queue_free()


func test_saving():
	describe("When saving the layout")
	for label in labels:
		label.text = "Test"
	LayoutUtils.save_layout(scene, "res://layout.json")
	var file := File.new()
	file.open("res://layout.json", File.READ)
	var json = parse_json(file.get_as_text())
	asserts.is_Dictionary(json, "Json is stored")
	asserts.is_Dictionary(json.windows, "Windows are stored")
	asserts.is_equal(json.windows.type, "VSplitContainer", "Container type is stored")
	asserts.is_equal(json.windows.split, scene.get_child(0).split_offset, "Split is stored")
	asserts.is_Array(json.windows.children, "Sub-Windows are stored")
	for child in json.windows.children[0].children[1].children:
		asserts.is_equal(str2var(child.data), "Test", "Data is stored")


func test_loading():
	describe("When loading a layout")
	LayoutUtils.load_layout(scene, "res://layout.json")
	for label in labels:
		asserts.is_equal(label.text, "Test", "Data is loaded")
