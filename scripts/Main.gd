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
var master_volume := 1.0
const SAVE_PATH: String = "user://save_data.cfg"

# ZAMANLI KOMBO SİSTEMİ
var combo_count := 0
var combo_timer: Timer

var score_label: Label
var high_score_label: Label
var combo_label: Label
var tray_container: Control
var game_over_panel: Control
var final_score_label: Label
var splash_panel: ColorRect

# PANELLER VE BUTONLAR
var start_menu_panel: Control
var settings_panel: Control
var volume_label: Label
var volume_slider: HSlider
var in_game_settings_btn: Button

# DİNAMİK BUTONLAR
var restart_btn: Button
var main_menu_btn: Button
var settings_card: Panel

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
	bg.mouse_filter = ColorRect.MOUSE_FILTER_IGNORE
	add_child(bg)
	
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

	# SAĞ ÜST AYARLAR BUTONU (OYUN İÇİ)
	in_game_settings_btn = Button.new()
	in_game_settings_btn.text = "⚙"
	in_game_settings_btn.position = Vector2(630, 30)
	in_game_settings_btn.custom_minimum_size = Vector2(55, 55)
	in_game_settings_btn.add_theme_font_size_override("font_size", 28)
	in_game_settings_btn.add_theme_color_override("font_color", Color("ffffff"))
	in_game_settings_btn.z_index = 80
	in_game_settings_btn.pressed.connect(func(): _open_settings(true))

	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color("3a3b5c")
	icon_style.corner_radius_top_left = 12
	icon_style.corner_radius_top_right = 12
	icon_style.corner_radius_bottom_left = 12
	icon_style.corner_radius_bottom_right = 12

	var icon_hover = icon_style.duplicate()
	icon_hover.bg_color = Color("2d2e47")

	in_game_settings_btn.add_theme_stylebox_override("normal", icon_style)
	in_game_settings_btn.add_theme_stylebox_override("hover", icon_hover)
	in_game_settings_btn.add_theme_stylebox_override("pressed", icon_hover)
	add_child(in_game_settings_btn)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	score_label.position = Vector2(40, 100)
	add_child(score_label)

	load_save_data()
	_apply_volume(master_volume)

	high_score_label = Label.new()
	high_score_label.text = "Best: %d" % high_score
	high_score_label.add_theme_font_size_override("font_size", 28)
	high_score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	high_score_label.position = Vector2(420, 100)
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

	start_menu_panel = Control.new()
	start_menu_panel.anchor_right = 1.0
	start_menu_panel.anchor_bottom = 1.0
	start_menu_panel.z_index = 150
	add_child(start_menu_panel)
	_build_start_menu_panel()

	settings_panel = Control.new()
	settings_panel.anchor_right = 1.0
	settings_panel.anchor_bottom = 1.0
	settings_panel.z_index = 160
	settings_panel.visible = false
	add_child(settings_panel)
	_build_settings_panel()

	_show_splash_screen()

# ANA MENÜ PANELİ
func _build_start_menu_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color("1a1a2e")
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	start_menu_panel.add_child(dim)

	var title_label = Label.new()
	title_label.text = "BLOCK BLAST"
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", Color("ffffff"))
	title_label.position = Vector2(0, 360)
	title_label.size = Vector2(720, 70)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_menu_panel.add_child(title_label)

	var menu_best_label = Label.new()
	menu_best_label.text = "BEST SCORE: %d" % high_score
	menu_best_label.add_theme_font_size_override("font_size", 32)
	menu_best_label.add_theme_color_override("font_color", Color("f1c40f"))
	menu_best_label.position = Vector2(0, 440)
	menu_best_label.size = Vector2(720, 50)
	menu_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_menu_panel.add_child(menu_best_label)

	var play_btn = Button.new()
	play_btn.text = "PLAY"
	play_btn.position = Vector2(210, 540)
	play_btn.custom_minimum_size = Vector2(300, 80)
	play_btn.add_theme_font_size_override("font_size", 36)
	play_btn.add_theme_color_override("font_color", Color("ffffff"))
	play_btn.pressed.connect(_on_start_game_pressed)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("2ed573")
	btn_style.corner_radius_top_left = 25
	btn_style.corner_radius_top_right = 25
	btn_style.corner_radius_bottom_left = 25
	btn_style.corner_radius_bottom_right = 25
	btn_style.border_width_bottom = 8
	btn_style.border_color = Color("26af5f")
	
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color("26af5f")

	play_btn.add_theme_stylebox_override("normal", btn_style)
	play_btn.add_theme_stylebox_override("hover", btn_hover)
	play_btn.add_theme_stylebox_override("pressed", btn_hover)

	start_menu_panel.add_child(play_btn)

	var settings_btn = Button.new()
	settings_btn.text = "⚙ AYARLAR"
	settings_btn.position = Vector2(240, 650)
	settings_btn.custom_minimum_size = Vector2(240, 65)
	settings_btn.add_theme_font_size_override("font_size", 26)
	settings_btn.add_theme_color_override("font_color", Color("ffffff"))
	settings_btn.pressed.connect(func(): _open_settings(false))

	var set_style = StyleBoxFlat.new()
	set_style.bg_color = Color("3a3b5c")
	set_style.corner_radius_top_left = 20
	set_style.corner_radius_top_right = 20
	set_style.corner_radius_bottom_left = 20
	set_style.corner_radius_bottom_right = 20
	set_style.border_width_bottom = 5
	set_style.border_color = Color("2d2e47")
	
	var set_hover = set_style.duplicate()
	set_hover.bg_color = Color("2d2e47")

	settings_btn.add_theme_stylebox_override("normal", set_style)
	settings_btn.add_theme_stylebox_override("hover", set_hover)
	settings_btn.add_theme_stylebox_override("pressed", set_hover)

	start_menu_panel.add_child(settings_btn)

# AYARLAR PANELİ
func _build_settings_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	settings_panel.add_child(dim)

	settings_card = Panel.new()
	settings_card.position = Vector2(100, 300)
	settings_card.custom_minimum_size = Vector2(520, 420)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color("222338")
	card_style.corner_radius_top_left = 30
	card_style.corner_radius_top_right = 30
	card_style.corner_radius_bottom_left = 30
	card_style.corner_radius_bottom_right = 30
	card_style.border_width_left = 3
	card_style.border_width_top = 3
	card_style.border_width_right = 3
	card_style.border_width_bottom = 3
	card_style.border_color = Color("3a3b5c")
	settings_card.add_theme_stylebox_override("panel", card_style)
	settings_panel.add_child(settings_card)

	var set_title = Label.new()
	set_title.text = "AYARLAR"
	set_title.add_theme_font_size_override("font_size", 38)
	set_title.add_theme_color_override("font_color", Color("ffffff"))
	set_title.position = Vector2(0, 25)
	set_title.size = Vector2(520, 50)
	set_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_card.add_child(set_title)

	volume_label = Label.new()
	volume_label.text = "SES DÜZEYİ: %d%%" % int(master_volume * 100)
	volume_label.add_theme_font_size_override("font_size", 24)
	volume_label.add_theme_color_override("font_color", Color("f1c40f"))
	volume_label.position = Vector2(0, 95)
	volume_label.size = Vector2(520, 35)
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_card.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = master_volume
	volume_slider.position = Vector2(60, 140)
	volume_slider.custom_minimum_size = Vector2(400, 40)
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_card.add_child(volume_slider)

	# 🔄 YENİDEN BAŞLAT BUTONU (Sadece oyun içinde görünür)
	restart_btn = Button.new()
	restart_btn.text = "🔄 YENİDEN BAŞLAT"
	restart_btn.position = Vector2(110, 205)
	restart_btn.custom_minimum_size = Vector2(300, 55)
	restart_btn.add_theme_font_size_override("font_size", 22)
	restart_btn.add_theme_color_override("font_color", Color("ffffff"))
	restart_btn.pressed.connect(_on_settings_restart_pressed)

	var rst_style = StyleBoxFlat.new()
	rst_style.bg_color = Color("e67e22")
	rst_style.corner_radius_top_left = 16
	rst_style.corner_radius_top_right = 16
	rst_style.corner_radius_bottom_left = 16
	rst_style.corner_radius_bottom_right = 16
	rst_style.border_width_bottom = 5
	rst_style.border_color = Color("d35400")
	restart_btn.add_theme_stylebox_override("normal", rst_style)
	restart_btn.add_theme_stylebox_override("hover", rst_style)
	restart_btn.add_theme_stylebox_override("pressed", rst_style)
	settings_card.add_child(restart_btn)

	# 🏠 ANA MENÜYE DÖN BUTONU (Sadece oyun içinde görünür)
	main_menu_btn = Button.new()
	main_menu_btn.text = "🏠 ANA MENÜ"
	main_menu_btn.position = Vector2(110, 275)
	main_menu_btn.custom_minimum_size = Vector2(300, 55)
	main_menu_btn.add_theme_font_size_override("font_size", 22)
	main_menu_btn.add_theme_color_override("font_color", Color("ffffff"))
	main_menu_btn.pressed.connect(_on_settings_menu_pressed)

	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = Color("2980b9")
	menu_style.corner_radius_top_left = 16
	menu_style.corner_radius_top_right = 16
	menu_style.corner_radius_bottom_left = 16
	menu_style.corner_radius_bottom_right = 16
	menu_style.border_width_bottom = 5
	menu_style.border_color = Color("2980b9").darkened(0.2)
	main_menu_btn.add_theme_stylebox_override("normal", menu_style)
	main_menu_btn.add_theme_stylebox_override("hover", menu_style)
	main_menu_btn.add_theme_stylebox_override("pressed", menu_style)
	settings_card.add_child(main_menu_btn)

	# ❌ DEVAM ET / KAPAT BUTONU
	var close_btn = Button.new()
	close_btn.text = "KAPAT"
	close_btn.position = Vector2(160, 345)
	close_btn.custom_minimum_size = Vector2(200, 50)
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color("ffffff"))
	close_btn.pressed.connect(_close_settings)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	close_style.border_width_bottom = 5
	close_style.border_color = Color("26af5f")

	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	settings_card.add_child(close_btn)

# AYARLARI AÇARKEN OYUN İÇİNDEN Mİ AÇILDIĞINI KONTROL EDER
func _open_settings(is_in_game: bool = false) -> void:
	if is_in_game:
		restart_btn.visible = true
		main_menu_btn.visible = true
		settings_card.custom_minimum_size = Vector2(520, 420)
		settings_card.position = Vector2(100, 300)
	else:
		restart_btn.visible = false
		main_menu_btn.visible = false
		settings_card.custom_minimum_size = Vector2(520, 270)
		settings_card.position = Vector2(100, 370)
		
	settings_panel.visible = true

func _close_settings() -> void:
	settings_panel.visible = false

func _on_settings_restart_pressed() -> void:
	_close_settings()
	_on_restart()

func _on_settings_menu_pressed() -> void:
	_close_settings()
	_on_restart()
	start_menu_panel.modulate.a = 1.0
	start_menu_panel.visible = true

func _on_volume_changed(val: float) -> void:
	master_volume = val
	volume_label.text = "SES DÜZEYİ: %d%%" % int(master_volume * 100)
	_apply_volume(master_volume)
	save_save_data()

func _apply_volume(val: float) -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		if val <= 0.001:
			AudioServer.set_bus_mute(bus_index, true)
		else:
			AudioServer.set_bus_mute(bus_index, false)
			var db = linear_to_db(val)
			AudioServer.set_bus_volume_db(bus_index, db)

func _on_start_game_pressed() -> void:
	if start_menu_panel:
		var tween = create_tween()
		tween.tween_property(start_menu_panel, "modulate:a", 0.0, 0.25)
		tween.tween_callback(func(): start_menu_panel.visible = false)
	_new_tray()

func load_save_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		high_score = config.get_value("game", "high_score", 0)
		master_volume = config.get_value("game", "master_volume", 1.0)
	else:
		high_score = 0
		master_volume = 1.0

func save_save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.set_value("game", "master_volume", master_volume)
	config.save(SAVE_PATH)

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

func _on_piece_placed(rows_cleared: int, cols_cleared: int, cells_placed: int) -> void:
	var total_cleared = rows_cleared + cols_cleared
	
	var place_multiplier = max(1, combo_count)
	score += (cells_placed * place_multiplier)

	if total_cleared > 0:
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
	
	if score > high_score:
		high_score = score
		high_score_label.text = "Best: %d" % high_score
		save_save_data()

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
