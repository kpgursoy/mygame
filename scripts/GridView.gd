extends Control
class_name GridView

signal piece_placed(cleared_lines: int)

const GRID_SIZE := 8

var cell_size := 64.0
var board: Array = []
var hover_cells: Array = []
var hover_valid := false

func _ready() -> void:
	custom_minimum_size = Vector2(GRID_SIZE * cell_size, GRID_SIZE * cell_size)
	size = custom_minimum_size
	_init_board()

func _init_board() -> void:
	board.clear()
	for y in range(GRID_SIZE):
		var row = []
		row.resize(GRID_SIZE)
		for x in range(GRID_SIZE):
			row[x] = null
		board.append(row)

func reset_board() -> void:
	_init_board()
	hover_cells = []
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(GRID_SIZE * cell_size, GRID_SIZE * cell_size)), Color(0.10, 0.11, 0.15))
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var r = Rect2(x * cell_size + 1, y * cell_size + 1, cell_size - 3, cell_size - 3)
			var c = board[y][x]
			if c != null:
				draw_rect(r, c)
			else:
				draw_rect(r, Color(0.17, 0.18, 0.23))
	if hover_cells.size() > 0:
		var hc = Color(0.3, 1.0, 0.4, 0.5) if hover_valid else Color(1.0, 0.25, 0.25, 0.5)
		for cell in hover_cells:
			if in_bounds(cell.x, cell.y):
				var r = Rect2(cell.x * cell_size + 1, cell.y * cell_size + 1, cell_size - 3, cell_size - 3)
				draw_rect(r, hc)

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < GRID_SIZE and y >= 0 and y < GRID_SIZE

func can_place(shape: Array, anchor: Vector2i) -> bool:
	for cell in shape:
		var x = anchor.x + cell.x
		var y = anchor.y + cell.y
		if not in_bounds(x, y):
			return false
		if board[y][x] != null:
			return false
	return true

func has_any_valid_placement(shape: Array) -> bool:
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			if can_place(shape, Vector2i(x, y)):
				return true
	return false

func place(shape: Array, anchor: Vector2i, color: Color) -> void:
	for cell in shape:
		var x = anchor.x + cell.x
		var y = anchor.y + cell.y
		board[y][x] = color
	var cleared = clear_lines()
	queue_redraw()
	piece_placed.emit(cleared)

func clear_lines() -> int:
	var rows_to_clear = []
	var cols_to_clear = []
	for y in range(GRID_SIZE):
		var full = true
		for x in range(GRID_SIZE):
			if board[y][x] == null:
				full = false
				break
		if full:
			rows_to_clear.append(y)
	for x in range(GRID_SIZE):
		var full = true
		for y in range(GRID_SIZE):
			if board[y][x] == null:
				full = false
				break
		if full:
			cols_to_clear.append(x)
	for y in rows_to_clear:
		for x in range(GRID_SIZE):
			board[y][x] = null
	for x in cols_to_clear:
		for y in range(GRID_SIZE):
			board[y][x] = null
	return rows_to_clear.size() + cols_to_clear.size()

func anchor_from_local(pos: Vector2, shape: Array) -> Vector2i:
	var max_x := 0
	var max_y := 0
	for cell in shape:
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	var w = (max_x + 1) * cell_size
	var h = (max_y + 1) * cell_size
	var top_left = pos - Vector2(w / 2.0, h / 2.0)
	var col = int(round(top_left.x / cell_size))
	var row = int(round(top_left.y / cell_size))
	return Vector2i(col, row)

func _can_drop_data(pos, data) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("shape"):
		hover_cells = []
		queue_redraw()
		return false
	var shape = data["shape"]
	var anchor = anchor_from_local(pos, shape)
	var valid = can_place(shape, anchor)
	hover_valid = valid
	hover_cells = []
	for cell in shape:
		hover_cells.append(Vector2i(anchor.x + cell.x, anchor.y + cell.y))
	queue_redraw()
	return valid

func _drop_data(pos, data) -> void:
	var shape = data["shape"]
	var color = data["color"]
	var anchor = anchor_from_local(pos, shape)
	hover_cells = []
	if can_place(shape, anchor):
		place(shape, anchor, color)
		if data.has("origin") and is_instance_valid(data["origin"]):
			data["origin"].mark_used()
	queue_redraw()
