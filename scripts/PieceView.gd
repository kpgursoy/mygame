extends Control
class_name PieceView

var shape: Array = []
var color: Color = Color.WHITE
var cell_size := 40.0
var used_flag := false

func setup(p_shape: Array, p_color: Color) -> void:
	shape = p_shape
	color = p_color
	var max_x := 0
	var max_y := 0
	for cell in shape:
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	custom_minimum_size = Vector2((max_x + 1) * cell_size, (max_y + 1) * cell_size)
	size = custom_minimum_size
	queue_redraw()

func _draw() -> void:
	if used_flag:
		return
	for cell in shape:
		var r = Rect2(cell.x * cell_size + 2, cell.y * cell_size + 2, cell_size - 6, cell_size - 6)
		draw_rect(r, color)

func _get_drag_data(_at_position: Vector2):
	if used_flag:
		return null

	var preview = Control.new()
	preview.custom_minimum_size = size
	preview.size = size
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pv_shape = shape
	var pv_color = color
	var pv_cell = cell_size
	preview.draw.connect(func():
		for cell in pv_shape:
			var r = Rect2(cell.x * pv_cell + 2, cell.y * pv_cell + 2, pv_cell - 6, pv_cell - 6)
			preview.draw_rect(r, pv_color)
	)
	preview.position = -size / 2.0
	set_drag_preview(preview)
	modulate.a = 0.3
	return {"shape": shape, "color": color, "origin": self}

func mark_used() -> void:
	used_flag = true
	modulate.a = 0.3
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not used_flag:
			modulate.a = 1.0
