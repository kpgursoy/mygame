extends Control
class_name GridView

signal piece_placed(cleared_lines: int, cells_placed: int)

const GRID_SIZE := 8

var cell_size := 64.0
var board: Array = []
var hover_cells: Array = []
var hover_valid := false
var hover_color := Color.WHITE

# Taşı sürüklerken kare değişimini takip etmek için
var last_hover_anchor := Vector2i(-999, -999) 

func _ready() -> void:
	custom_minimum_size = Vector2(GRID_SIZE * cell_size, GRID_SIZE * cell_size)
	size = custom_minimum_size
	
	# OTOMATİK ORTALAMA: Ekranın tam ortasına yatayda kilitler
	anchors_preset = Control.PRESET_CENTER_TOP
	anchor_left = 0.5
	anchor_right = 0.5
	offset_left = -(GRID_SIZE * cell_size) / 2.0
	offset_right = (GRID_SIZE * cell_size) / 2.0
	
	_init_board()
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_exited() -> void:
	hover_cells.clear()
	last_hover_anchor = Vector2i(-999, -999) # Dışarı çıkınca sıfırla
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
	last_hover_anchor = Vector2i(-999, -999)
	queue_redraw()

func _draw() -> void:
	# Arka plan paneli
	draw_rect(Rect2(Vector2.ZERO, Vector2(GRID_SIZE * cell_size, GRID_SIZE * cell_size)), Color(0.10, 0.11, 0.15))
	
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var r = Rect2(x * cell_size + 1, y * cell_size + 1, cell_size - 3, cell_size - 3)
			var c = board[y][x]
			
			if c != null:
				_draw_styled_block(r, c)
			else:
				# Boş kareler için yuvarlatılmış mat kutu
				_draw_styled_block(r, Color(0.17, 0.18, 0.23), true)

	# Sürüklerken gösterilen önizleme (yarı saydam siluet)
	if hover_cells.size() > 0:
		var hc = hover_color
		hc.a = 0.45 if hover_valid else 0.25
		if not hover_valid:
			hc = Color(0.9, 0.2, 0.2, 0.35) # Geçersiz yerleşimse şeffaf kırmızı
			
		for cell in hover_cells:
			if in_bounds(cell.x, cell.y):
				var r = Rect2(cell.x * cell_size + 1, cell.y * cell_size + 1, cell_size - 3, cell_size - 3)
				_draw_styled_block(r, hc)

# Blokları modern, yuvarlatılmış ve 3D görünümlü çizen fonksiyon
func _draw_styled_block(rect: Rect2, color: Color, is_empty: bool = false) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	
	# Köşe yuvarlatma (Block Blast tarzı kavis)
	var radius = int(rect.size.x * 0.18)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	
	if not is_empty:
		# Kenarlara parlaklık/kabartma çizgisi ekler
		style.border_width_top = 3
		style.border_width_left = 3
		style.border_width_bottom = 3
		style.border_width_right = 3
		style.border_color = color.lightened(0.35)
	
	draw_style_box(style, rect)

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
	piece_placed.emit(cleared, shape.size())

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
		
		# Güçlü Patlama Animasyonu & Parçacıklar
		_animate_clearing_cells_v2(cells_to_animate, total_cleared)
		
	return total_cleared

# GÜÇLÜ PATLAMA & PARÇACIK ANİMASYONU
func _animate_clearing_cells_v2(cells: Array, intensity: int) -> void:
	var anim_container = Node2D.new()
	add_child(anim_container)
	
	# GRID SARSINTISI (Screen Shake)
	var original_pos = position
	var shake_tween = create_tween()
	for i in range(5):
		var offset = Vector2(randf_range(-6, 6), randf_range(-6, 6)) * intensity
		shake_tween.tween_property(self, "position", original_pos + offset, 0.03)
	shake_tween.tween_property(self, "position", original_pos, 0.03)
	
	for cell in cells:
		var color = board[cell.y][cell.x]
		if color == null:
			continue
			
		board[cell.y][cell.x] = null
		
		var center_pos = Vector2(cell.x * cell_size + cell_size / 2.0, cell.y * cell_size + cell_size / 2.0)
		
		# 1. PARÇACIK PATLAMASI (Kıvılcımlar/Konfetiler)
		var particles = CPUParticles2D.new()
		particles.position = center_pos
		particles.emitting = false
		particles.one_shot = true
		particles.amount = 14
		particles.lifetime = 0.4
		particles.explosiveness = 0.9
		particles.spread = 180.0
		particles.gravity = Vector2(0, 400) # Aşağı doğru düşüş
		particles.initial_velocity_min = 100.0
		particles.initial_velocity_max = 220.0
		particles.scale_amount_min = 4.0
		particles.scale_amount_max = 8.0
		particles.color = color.lightened(0.2)
		anim_container.add_child(particles)
		particles.emitting = true
		
		# 2. PATLAYAN BLOK GÖRSELİ
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
		
		# TWEEN ANİMASYONU: Hızla büyüyüp parlayarak kaybolma
		var tween = create_tween().set_parallel(true)
		tween.tween_property(temp_block, "scale", Vector2(1.35, 1.35), 0.1).set_trans(Tween.TRANS_BACK)
		tween.tween_property(temp_block, "modulate", Color(2.0, 2.0, 2.0, 0.0), 0.18).set_trans(Tween.TRANS_QUAD)
	
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

func _can_drop_data(pos: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("shape"):
		hover_cells = []
		last_hover_anchor = Vector2i(-999, -999)
		queue_redraw()
		return false
		
	var shape = data["shape"]
	if data.has("color"):
		hover_color = data["color"]
		
	var anchor = anchor_from_local(pos, shape)
	
	if anchor != last_hover_anchor:
		last_hover_anchor = anchor
		Input.vibrate_handheld(15)
	
	var valid = can_place(shape, anchor)
	hover_valid = valid
	hover_cells = []
	for cell in shape:
		hover_cells.append(Vector2i(anchor.x + cell.x, anchor.y + cell.y))
	queue_redraw()
	return valid

func _drop_data(pos: Vector2, data: Variant) -> void:
	var shape = data["shape"]
	var color = data["color"]
	var anchor = anchor_from_local(pos, shape)
	hover_cells = []
	last_hover_anchor = Vector2i(-999, -999)
	
	if can_place(shape, anchor):
		place(shape, anchor, color)
		if data.has("origin") and is_instance_valid(data["origin"]):
			data["origin"].mark_used()
	queue_redraw()
