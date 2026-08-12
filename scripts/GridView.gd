extends Control
class_name GridView

signal piece_placed(rows_cleared: int, cols_cleared: int, cells_placed: int)
signal cell_clicked_for_joker(cell_pos: Vector2i)

const GRID_SIZE := 8

var cell_size := 64.0
var board: Array = []
var hover_cells: Array = []
var hover_valid := false
var hover_color := Color.WHITE

var last_hover_anchor := Vector2i(-999, -999) 

# === YENİ: Patlayacak hücreleri tutacağımız liste ===
var preview_clear_cells: Array = [] 

func _ready() -> void:
	custom_minimum_size = Vector2(GRID_SIZE * cell_size, GRID_SIZE * cell_size)
	size = custom_minimum_size
	
	anchors_preset = Control.PRESET_CENTER_TOP
	anchor_left = 0.5
	anchor_right = 0.5
	offset_left = -(GRID_SIZE * cell_size) / 2.0
	offset_right = (GRID_SIZE * cell_size) / 2.0
	
	_init_board()
	mouse_exited.connect(_on_mouse_exited)

# === YENİ: Animasyonun akıcı olması için ekranı yenileme ===
func _process(_delta: float) -> void:
	if preview_clear_cells.size() > 0:
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var col = int(event.position.x / cell_size)
		var row = int(event.position.y / cell_size)
		if in_bounds(col, row):
			cell_clicked_for_joker.emit(Vector2i(col, row))

func _on_mouse_exited() -> void:
	hover_cells.clear()
	preview_clear_cells.clear() # Temizlik
	last_hover_anchor = Vector2i(-999, -999)
	queue_redraw()

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
	preview_clear_cells.clear() # Temizlik
	last_hover_anchor = Vector2i(-999, -999)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(GRID_SIZE * cell_size, GRID_SIZE * cell_size)), Color(0.10, 0.11, 0.15))
	
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var r = Rect2(x * cell_size + 1, y * cell_size + 1, cell_size - 3, cell_size - 3)
			var c = board[y][x]
			
			if c != null:
				_draw_styled_block(r, c)
			else:
				_draw_styled_block(r, Color(0.17, 0.18, 0.23), true)

	if hover_cells.size() > 0:
		var hc = hover_color
		hc.a = 0.45 
			
		for cell in hover_cells:
			if in_bounds(cell.x, cell.y):
				var r = Rect2(cell.x * cell_size + 1, cell.y * cell_size + 1, cell_size - 3, cell_size - 3)
				_draw_styled_block(r, hc)

	# === YENİ: ANİMASYONLU PARLAMA ÇİZİMİ ===
	if preview_clear_cells.size() > 0:
		# Zamanı alıp sinüs dalgasına çeviriyoruz (Nefes alma efekti)
		var time = Time.get_ticks_msec() / 150.0 
		var pulse = (sin(time) + 1.0) / 2.0 # 0.0 ile 1.0 arası yumuşak geçiş
		
		# Saydamlığı nabız gibi attır (0.15 ile 0.55 arasında gidip gelir)
		var current_alpha = 0.15 + (pulse * 0.40)
		var glow_color = Color(1.0, 1.0, 1.0, current_alpha) 
		var border_color = Color(1.0, 1.0, 1.0, current_alpha + 0.3) 
		
		for cell in preview_clear_cells:
			if in_bounds(cell.x, cell.y):
				var r = Rect2(cell.x * cell_size + 1, cell.y * cell_size + 1, cell_size - 3, cell_size - 3)
				var style = StyleBoxFlat.new()
				
				style.bg_color = glow_color
				
				style.border_width_top = 2
				style.border_width_left = 2
				style.border_width_bottom = 2
				style.border_width_right = 2
				style.border_color = border_color
				
				var radius = int(r.size.x * 0.18)
				style.corner_radius_top_left = radius
				style.corner_radius_top_right = radius
				style.corner_radius_bottom_left = radius
				style.corner_radius_bottom_right = radius
				
				draw_style_box(style, r)

func _draw_styled_block(rect: Rect2, color: Color, is_empty: bool = false) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	
	var radius = int(rect.size.x * 0.18)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	
	if not is_empty:
		style.border_width_top = 3
		style.border_width_left = 3
		style.border_width_bottom = 3
		style.border_width_right = 3
		style.border_color = color.lightened(0.35)
	
	draw_style_box(style, rect)

func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < GRID_SIZE and y >= 0 and y < GRID_SIZE

# JOKER: TEK KARE KIRMA (HAMMER)
func use_hammer(cell: Vector2i) -> bool:
	if in_bounds(cell.x, cell.y) and board[cell.y][cell.x] != null:
		_animate_clearing_cells_v2([cell], 2)
		return true
	return false

# JOKER: 3x3 ALAN PATLATMA (BOMB)
func use_bomb(center_cell: Vector2i) -> bool:
	var cells_to_clear: Array = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var cx = center_cell.x + dx
			var cy = center_cell.y + dy
			if in_bounds(cx, cy) and board[cy][cx] != null:
				cells_to_clear.append(Vector2i(cx, cy))
				
	if cells_to_clear.size() > 0:
		_animate_clearing_cells_v2(cells_to_clear, 4)
		return true
	return false

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
	
	var cleared_data = clear_lines()
	queue_redraw()
	
	piece_placed.emit(cleared_data[0], cleared_data[1], shape.size())

func clear_lines() -> Array:
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
			
	var total_cleared = rows_to_clear.size() + cols_to_clear.size()
	
	if total_cleared > 0:
		var cells_to_animate: Array = []
		
		for y in rows_to_clear:
			for x in range(GRID_SIZE):
				if not Vector2i(x, y) in cells_to_animate:
					cells_to_animate.append(Vector2i(x, y))
					
		for x in cols_to_clear:
			for y in range(GRID_SIZE):
				if not Vector2i(x, y) in cells_to_animate:
					cells_to_animate.append(Vector2i(x, y))
		
		_animate_clearing_cells_v2(cells_to_animate, total_cleared)
		
	return [rows_to_clear.size(), cols_to_clear.size()]

func trigger_shake(intensity: int) -> void:
	var original_pos = position
	var shake_tween = create_tween()
	var shake_count = 6 + (intensity * 2)
	var max_offset = 5.0 + (intensity * 3.0)
	
	for i in range(shake_count):
		var offset = Vector2(randf_range(-max_offset, max_offset), randf_range(-max_offset, max_offset))
		shake_tween.tween_property(self, "position", original_pos + offset, 0.025)
	shake_tween.tween_property(self, "position", original_pos, 0.025)

func _animate_clearing_cells_v2(cells: Array, intensity: int) -> void:
	var anim_container = Node2D.new()
	add_child(anim_container)
	
	trigger_shake(intensity)
	
	for cell in cells:
		var color = board[cell.y][cell.x]
		if color == null:
			color = Color.WHITE
			
		board[cell.y][cell.x] = null
		
		var center_pos = Vector2(cell.x * cell_size + cell_size / 2.0, cell.y * cell_size + cell_size / 2.0)
		
		var particles = CPUParticles2D.new()
		particles.position = center_pos
		particles.emitting = false
		particles.one_shot = true
		particles.amount = 16
		particles.lifetime = 0.45
		particles.explosiveness = 0.95
		particles.spread = 180.0
		particles.gravity = Vector2(0, 450)
		particles.initial_velocity_min = 120.0
		particles.initial_velocity_max = 250.0
		particles.scale_amount_min = 4.0
		particles.scale_amount_max = 9.0
		particles.color = color.lightened(0.25)
		anim_container.add_child(particles)
		particles.emitting = true
		
		var r = Rect2(cell.x * cell_size + 1, cell.y * cell_size + 1, cell_size - 3, cell_size - 3)
		var temp_block = Control.new()
		temp_block.position = r.position
		temp_block.size = r.size
		temp_block.pivot_offset = r.size / 2.0
		
		var block_color = color
		temp_block.draw.connect(func():
			var local_rect = Rect2(Vector2.ZERO, r.size)
			_draw_styled_block(local_rect, block_color)
		)
		
		anim_container.add_child(temp_block)
		temp_block.queue_redraw()
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(temp_block, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_BACK)
		tween.tween_property(temp_block, "modulate", Color(2.5, 2.5, 2.5, 0.0), 0.2).set_trans(Tween.TRANS_QUAD)
	
	queue_redraw()
	
	await get_tree().create_timer(0.45).timeout
	anim_container.queue_free()

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

func get_closest_valid_anchor(shape: Array, target_anchor: Vector2i) -> Vector2i:
	var best_anchor = Vector2i(-999, -999)
	var min_dist = 2.0

	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var test_anchor = Vector2i(x, y)
			
			if can_place(shape, test_anchor):
				var dist = Vector2(test_anchor).distance_to(Vector2(target_anchor))
				if dist < min_dist:
					min_dist = dist
					best_anchor = test_anchor

	return best_anchor

func _can_drop_data(pos: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("shape"):
		hover_cells = []
		preview_clear_cells.clear() # Temizlik
		last_hover_anchor = Vector2i(-999, -999)
		queue_redraw()
		return false
		
	var shape = data["shape"]
	if data.has("color"):
		hover_color = data["color"]
		
	var raw_anchor = anchor_from_local(pos, shape)
	var best_anchor = get_closest_valid_anchor(shape, raw_anchor)
	
	if best_anchor == Vector2i(-999, -999):
		hover_cells = []
		preview_clear_cells.clear() # Temizlik
		last_hover_anchor = Vector2i(-999, -999)
		queue_redraw()
		return false
	
	if best_anchor != last_hover_anchor:
		last_hover_anchor = best_anchor
		Input.vibrate_handheld(15)
		
		if AudioManager.has_node("SfxHover"):
			AudioManager.get_node("SfxHover").play()
	
	hover_valid = true
	hover_cells = []
	for cell in shape:
		hover_cells.append(Vector2i(best_anchor.x + cell.x, best_anchor.y + cell.y))
		
	# === YENİ: SİMÜLASYON BAŞLANGICI ===
	preview_clear_cells.clear()
	
	var temp_board = []
	for y in range(GRID_SIZE):
		temp_board.append(board[y].duplicate())
		
	for hc in hover_cells:
		temp_board[hc.y][hc.x] = hover_color
		
	var rows_to_clear = []
	var cols_to_clear = []
	
	for y in range(GRID_SIZE):
		var full = true
		for x in range(GRID_SIZE):
			if temp_board[y][x] == null:
				full = false
				break
		if full:
			rows_to_clear.append(y)
			
	for x in range(GRID_SIZE):
		var full = true
		for y in range(GRID_SIZE):
			if temp_board[y][x] == null:
				full = false
				break
		if full:
			cols_to_clear.append(x)
			
	for y in rows_to_clear:
		for x in range(GRID_SIZE):
			var cell_pos = Vector2i(x, y)
			if not cell_pos in preview_clear_cells:
				preview_clear_cells.append(cell_pos)
				
	for x in cols_to_clear:
		for y in range(GRID_SIZE):
			var cell_pos = Vector2i(x, y)
			if not cell_pos in preview_clear_cells:
				preview_clear_cells.append(cell_pos)
	# === SİMÜLASYON BİTİŞİ ===

	queue_redraw()
	return true

func _drop_data(pos: Vector2, data: Variant) -> void:
	var shape = data["shape"]
	var color = data["color"]
	
	var raw_anchor = anchor_from_local(pos, shape)
	var best_anchor = get_closest_valid_anchor(shape, raw_anchor)
	
	hover_cells = []
	preview_clear_cells.clear() # Temizlik
	last_hover_anchor = Vector2i(-999, -999)
	
	if best_anchor != Vector2i(-999, -999):
		if AudioManager.has_node("SfxPlace"):
			AudioManager.get_node("SfxPlace").play()
		
		place(shape, best_anchor, color)
		if data.has("origin") and is_instance_valid(data["origin"]):
			data["origin"].mark_used()
	queue_redraw()
