# Customizable UI: UI 2.0 for the Godot Engine

This addon allows you to add UI 2.0 to your game/application made in Godot.

## Features

Panels can be arranged in vertical and horizontal lists, tabbed containers or popped out into resizable windows.

To rearrange a panel, drag the title above another window. A preview of the window placement will be rendered as a blue rectangle.

To pop windows out and back in, click the button to the right of the title.

## Usage

Add an instance of the `window_drag_receiver.tscn` scene at the bottom of your tree.
See below why this is needed.

Add `window.tscn` scenes for every panel you need, set the `title` and add the content as child nodes.
Then use nested `Split` - and `TabContainers` to arrange them. `SplitContainers` only support two children.

## How It Works

The `window_drag_receiver` scene is necesarry to allow dropping of window data at any position on screen. It is only visible when the drag data is a window.

After dropping the data, it calls `place_window_ontop` on all nodes in the `Window` group. The window below the cursor then rearranges the containers according to the drop position.

## Planned Features

In Godot 4.0, Godot's `Popup` nodes will become actual sub-windows, which will make popping out panels much more useful with hopefully not much code changed.
