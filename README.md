# Block Blast (Godot 4)

A Tetris-block-style puzzle game: drag pieces from the tray onto the 8x8
grid. Filling an entire row or column clears it and scores points. The
game ends when none of the 3 tray pieces can be placed anywhere.

## How to run

1. Install **Godot 4.2+** (Standard/GL Compatibility build): https://godotengine.org/download
2. Open Godot, click **Import**, and select the `project.godot` file in this
   folder (unzip the archive first).
3. Press the **Play** button (or F5). It will run `scenes/Main.tscn`.

## How to play

- Drag a piece from the tray at the bottom onto the grid.
- Green highlight = valid placement, red = invalid.
- Fill a full row or column to clear it and earn bonus points.
- When all 3 tray pieces are used, a new set of 3 spawns.
- Game over when no piece in the tray fits anywhere on the board.

## Exporting to .exe / .apk / etc.

This zip contains the **project source only** — actual platform builds
(Windows .exe, macOS .app, Android .apk, Web/HTML5, etc.) need to be
produced by Godot's export system, which requires the Godot editor plus
platform-specific export templates installed locally (these can't be
generated without running the Godot engine itself). To export:

1. Open the project in Godot.
2. Go to **Project > Export...**
3. Add a preset for your target platform (Godot will prompt to download
   export templates if missing).
4. Click **Export Project**.

## Project structure

```
BlockBlast/
├── project.godot          # Project settings
├── scenes/
│   └── Main.tscn           # Root scene
├── scripts/
│   ├── Main.gd              # Game controller (score, tray, game over)
│   ├── GridView.gd          # 8x8 board, drop handling, line clearing
│   └── PieceView.gd         # Draggable tray piece
└── README.md
```

All pieces, colors, and grid size are defined as simple arrays/constants
at the top of `Main.gd` and `GridView.gd` if you want to tweak difficulty,
add new piece shapes, or resize the board.
