# Customizable UI: UI 2.0 for the Godot Engine

This addon allows you to add modern UI customization features to your Godot game/application.

## Features

Panels can be arranged in vertical and horizontal lists, tabbed containers or popped out into resizable windows.

To rearrange a panel, drag the title above another window. A preview of the window placement will be rendered as a blue rectangle.

To pop windows out and back in, click the button to the right of the title.

The drop preview is a `StyleBox` and can be customized.

## Usage

Add an instance of the `window_drag_receiver.tscn` scene at the bottom of your tree.
See below why this is needed.

Add `window.tscn` scenes for every panel you need, set the `title` and add the content as child nodes.
Then use nested `Split` - and `TabContainers` to arrange them. `SplitContainers` only support two children.

Make sure to enable "Drag To Rearrange" on `TabContainers`, because otherwise they can't be dragged.

### Customizing the drop preview

The drop preview uses the `preview` `StyleBox` of the `WindowDragReceiver` node. By default it is the `drop_preview.stylebox` located in the addon folder.

### Saving And Loading Layouts

To save and load layouts, reference and use `layout_utils.gd`.

**Example:**

```gdscript
# the scene layout:
# Root (Control)
# ┗ Container (HSplitContainer)
#   ┣ Panel (window.gd)
#   ┗ Panel (window.gd)

const LayoutUtils = preload("res://addons/customizable_ui/layout_utils.gd")

# save a layout in the user folder. The first argument is the root container with panels inside.
LayoutUtils.save_layout($Root/Container, "user://layout.json")

# load a layout. The first argument is the parent of the root container.
LayoutUtils.load_layout($Root, "user://layout.json")
```

## How It Works

The `window_drag_receiver` scene is necesarry to allow dropping of window data at any position on screen. It is only visible when the drag data is a window.

After dropping the data, it calls `place_window_ontop` on all nodes in the `Window` group. The window below the cursor then rearranges the containers according to the drop position.

## Planned Features

In Godot 4.0, Godot's `Popup` nodes will become actual sub-windows, which will make popping out panels much more useful with hopefully not much code changed.
