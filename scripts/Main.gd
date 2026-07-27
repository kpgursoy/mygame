extends Control

var shapes: Array = [
	[Vector2i(0, 0)],
	[Vector2i(0, 0), Vector2i(1, 0)],
	[Vector2i(0, 0), Vector2i(0, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2)],
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, 2)],
]

var colors: Array = [
	Color("e74c3c"), Color("3498db"), Color("2ecc71"), Color("f1c40f"),
	Color("9b59b6"), Color("e67e22"), Color("1abc9c"), Color("e84393"),
]

var grid: GridView
var tray: Array = []
var score := 0
var high_score := 0

var score_label: Label
var high_score_label: Label
var tray_container: Control
var game_over_panel: Control
var final_score_label: Label

func _ready() -> void:
	randomize()
	mouse_filter = Control.MOUSE_FILTER_PASS

	var bg = ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var title = Label.new()
	title.text = "BLOCK BLAST"
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color("f5f5f5"))
	title.position = Vector2(0, 30)
	title.size = Vector2(720, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	score_label.position = Vector2(40, 100)
	add_child(score_label)

	high_score_label = Label.new()
	high_score_label.text = "Best: 0"
	high_score_label.add_theme_font_size_override("font_size", 28)
	high_score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	high_score_label.position = Vector2(460, 100)
	add_child(high_score_label)

	grid = GridView.new()
	grid.position = Vector2(64, 170)
	grid.piece_placed.connect(_on_piece_placed)
	add_child(grid)

	tray_container = Control.new()
	tray_container.position = Vector2(0, 920)
	tray_container.size = Vector2(720, 260)
	tray_container.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(tray_container)

	game_over_panel = Control.new()
	game_over_panel.visible = false
	game_over_panel.anchor_right = 1.0
	game_over_panel.anchor_bottom = 1.0
	add_child(game_over_panel)
	_build_game_over_panel()

	_new_tray()

func _build_game_over_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	game_over_panel.add_child(dim)

	var label = Label.new()
	label.text = "Game Over"
	label.add_theme_font_size_override("font_size", 56)
	label.add_theme_color_override("font_color", Color("ffffff"))
	label.position = Vector2(0, 520)
	label.size = Vector2(720, 70)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(label)

	final_score_label = Label.new()
	final_score_label.add_theme_font_size_override("font_size", 32)
	final_score_label.add_theme_color_override("font_color", Color("f1c40f"))
	final_score_label.position = Vector2(0, 600)
	final_score_label.size = Vector2(720, 50)
	final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(final_score_label)

	var btn = Button.new()
	btn.text = "Play Again"
	btn.position = Vector2(260, 690)
	btn.custom_minimum_size = Vector2(200, 60)
	btn.pressed.connect(_on_restart)
	game_over_panel.add_child(btn)

func _new_tray() -> void:
	for p in tray:
		if is_instance_valid(p):
			p.queue_free()
	tray.clear()

	var slot_width = 720 / 3
	for i in range(3):
		var shape = shapes[randi() % shapes.size()]
		var color = colors[randi() % colors.size()]
		var pv = PieceView.new()
		pv.setup(shape, color)
		pv.position = Vector2(slot_width * i + slot_width / 2.0 - pv.size.x / 2.0, 80)
		tray_container.add_child(pv)
		tray.append(pv)

	_check_game_over()

func _on_piece_placed(cleared: int) -> void:
	score += 1
	if cleared > 0:
		score += cleared * cleared * 10
	score_label.text = "Score: %d" % score
	if score > high_score:
		high_score = score
		high_score_label.text = "Best: %d" % high_score

	await get_tree().process_frame

	var all_used = true
	for p in tray:
		if is_instance_valid(p) and not p.used_flag:
			all_used = false
			break

	if all_used:
		_new_tray()
	else:
		_check_game_over()

func _check_game_over() -> void:
	var any_playable = false
	for p in tray:
		if is_instance_valid(p) and not p.used_flag:
			if grid.has_any_valid_placement(p.shape):
				any_playable = true
				break
	if not any_playable:
		_show_game_over()

func _show_game_over() -> void:
	final_score_label.text = "Score: %d" % score
	game_over_panel.visible = true

func _on_restart() -> void:
	game_over_panel.visible = false
	score = 0
	score_label.text = "Score: 0"
	grid.reset_board()
	_new_tray()
