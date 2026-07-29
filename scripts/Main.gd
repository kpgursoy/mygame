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
const SAVE_PATH: String = "user://save_data.cfg" # Rekor kayıt dosyası

# YENİ ZAMANLI KOMBO SİSTEMİ
var combo_count := 0 
var combo_timer: Timer

var score_label: Label
var high_score_label: Label
var combo_label: Label
var tray_container: Control
var game_over_panel: Control
var final_score_label: Label
var splash_panel: ColorRect 

var combo_tween: Tween 

var studio_name_text := "BONET GAMES" 
var logo_path := "res://logo.png"

func _ready() -> void:
	randomize()
	mouse_filter = Control.MOUSE_FILTER_PASS

	var bg = ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	# ZAMANLAYICIYI OLUŞTUR (8 Saniye)
	combo_timer = Timer.new()
	combo_timer.wait_time = 8.0
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)
	add_child(combo_timer)

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

	# KAYITLI REKORU YÜKLE
	load_high_score()

	high_score_label = Label.new()
	high_score_label.text = "Best: %d" % high_score
	high_score_label.add_theme_font_size_override("font_size", 28)
	high_score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	high_score_label.position = Vector2(460, 100)
	add_child(high_score_label)
	
	combo_label = Label.new()
	combo_label.text = "COMBO x1!"
	combo_label.add_theme_font_size_override("font_size", 32)
	combo_label.add_theme_color_override("font_color", Color("ff9f43")) 
	combo_label.position = Vector2(0, 130)
	combo_label.size = Vector2(720, 50)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.pivot_offset = combo_label.size / 2.0 
	combo_label.visible = false
	combo_label.z_index = 50 
	add_child(combo_label)

	grid = GridView.new()
	grid.position = Vector2(64, 180)
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
	game_over_panel.z_index = 100 
	add_child(game_over_panel)
	_build_game_over_panel()

	_new_tray()
	_show_splash_screen()

# REKORU DOSYADAN OKU
func load_high_score() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		high_score = config.get_value("game", "high_score", 0)
	else:
		high_score = 0

# REKORU DOSYAYA KAYDET
func save_high_score() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.save(SAVE_PATH)

# 8 Saniye Dolduğunda Çalışır
func _on_combo_timeout() -> void:
	combo_count = 0
	if combo_label.visible and not (combo_tween and combo_tween.is_valid()):
		combo_label.visible = false

func _show_splash_screen() -> void:
	splash_panel = ColorRect.new()
	splash_panel.color = Color("0d0d14") 
	splash_panel.anchor_right = 1.0
	splash_panel.anchor_bottom = 1.0
	splash_panel.z_index = 200 
	add_child(splash_panel)

	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	splash_panel.add_child(vbox)

	if ResourceLoader.exists(logo_path):
		var logo = TextureRect.new()
		logo.texture = load(logo_path)
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE 
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.custom_minimum_size = Vector2(220, 220) 
		vbox.add_child(logo)

	var st_label = Label.new()
	st_label.text = studio_name_text
	st_label.add_theme_font_size_override("font_size", 48)
	st_label.add_theme_color_override("font_color", Color("ffffff"))
	st_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(st_label)

	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(splash_panel, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(splash_panel.queue_free)

func _build_game_over_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0.05, 0.05, 0.1, 0.85)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	game_over_panel.add_child(dim)

	var label = Label.new()
	label.text = "GAME OVER"
	label.add_theme_font_size_override("font_size", 56)
	label.add_theme_color_override("font_color", Color("ff4757"))
	label.position = Vector2(0, 480)
	label.size = Vector2(720, 70)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(label)

	final_score_label = Label.new()
	final_score_label.add_theme_font_size_override("font_size", 36)
	final_score_label.add_theme_color_override("font_color", Color("ffa502"))
	final_score_label.position = Vector2(0, 560)
	final_score_label.size = Vector2(720, 50)
	final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(final_score_label)

	var btn = Button.new()
	btn.text = "PLAY AGAIN"
	btn.position = Vector2(220, 650)
	btn.custom_minimum_size = Vector2(280, 70)
	btn.add_theme_font_size_override("font_size", 28)
	btn.add_theme_color_override("font_color", Color("ffffff"))
	btn.pressed.connect(_on_restart)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("2ed573")
	btn_style.corner_radius_top_left = 20
	btn_style.corner_radius_top_right = 20
	btn_style.corner_radius_bottom_left = 20
	btn_style.corner_radius_bottom_right = 20
	btn_style.border_width_bottom = 6
	btn_style.border_color = Color("26af5f")
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color("26af5f")

	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_stylebox_override("hover", btn_hover)
	btn.add_theme_stylebox_override("pressed", btn_hover)

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

# YENİ SİNYALE GÖRE GÜNCELLENMİŞ FONKSİYON
func _on_piece_placed(rows_cleared: int, cols_cleared: int, cells_placed: int) -> void:
	var total_cleared = rows_cleared + cols_cleared
	
	var place_multiplier = max(1, combo_count)
	score += (cells_placed * place_multiplier)

	if total_cleared > 0:
		# PATLATMA HESAPLAMALARI
		var added_combo = 0
		
		if rows_cleared > 0 and cols_cleared > 0:
			added_combo = total_cleared * 4
		else:
			added_combo = total_cleared * 2
			
		combo_count += added_combo
		combo_timer.start()
		
		var base_clear_score = total_cleared * total_cleared * 10 
		score += base_clear_score * combo_count
		
		if AudioManager.has_node("SfxBlast"):
			var blast_sfx = AudioManager.get_node("SfxBlast")
			blast_sfx.pitch_scale = min(1.0 + (combo_count - 1) * 0.15, 2.0)
			blast_sfx.play()
		
		var vibration_time = min(100 + (combo_count * 30), 250)
		Input.vibrate_handheld(vibration_time)
		
		if combo_count >= 1:
			combo_label.text = "COMBO x%d!" % combo_count
			combo_label.visible = true
			combo_label.modulate.a = 1.0 
			
			if combo_tween and combo_tween.is_valid():
				combo_tween.kill()
				
			combo_tween = create_tween()
			combo_label.scale = Vector2(1.5, 1.5) 
			
			combo_tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BOUNCE)
			combo_tween.tween_interval(0.8)
			combo_tween.tween_property(combo_label, "modulate:a", 0.0, 0.4)
			combo_tween.tween_callback(func(): combo_label.visible = false)
	else:
		Input.vibrate_handheld(40)

	score_label.text = "Score: %d" % score
	
	# REKOR KONTROLÜ VE DOSYAYA KAYDETME
	if score > high_score:
		high_score = score
		high_score_label.text = "Best: %d" % high_score
		save_high_score()

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
		Input.vibrate_handheld(500) 

func _show_game_over() -> void:
	combo_timer.stop()
	final_score_label.text = "Score: %d" % score
	game_over_panel.visible = true

func _on_restart() -> void:
	game_over_panel.visible = false
	score = 0
	combo_count = 0 
	combo_timer.stop()
	combo_label.visible = false
	score_label.text = "Score: 0"
	grid.reset_board()
	_new_tray()
