# M3 UI / Play Area Layout Fix

- Play Area is fixed at 1280x720 (16:9).
- UI is additional to the Play Area: 220 px left + 124 px top.
- Total logical canvas: 1500x844 (~16:9).
- Project stretch: canvas_items + keep.
- Project starts fullscreen.
- Field backgrounds are rendered only inside the Play Area rect (220,124)-(1500,844).
- Grid/board uses the same Play Area coordinate space, so it stays aligned with the background.
- TopBar spans the complete logical canvas width.
- PlantPanel occupies the left UI column below the TopBar.

Note: The Godot Editor Embedded Game view may still show the logical canvas inside the editor. For a true fullscreen test, run the project as a standalone window.
