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
var gold_amount := 100
const SAVE_PATH: String = "user://save_data.cfg"

# ELDEKİ JOKER ADETLERİ (ENVANTER)
var hammer_count := 3
var bomb_count := 1
var reroll_count := 2

# KOMBO VE STREAK SİSTEMİ
var combo_count := 0
var streak_count := 0
var combo_timer: Timer

var score_label: Label
var high_score_label: Label
var gold_label: Label
var tray_container: Control
var game_over_panel: Control
var final_score_label: Label
var splash_panel: ColorRect
var revive_btn: Button

# JOKER FİYATLARI VE SİSTEMİ
const COST_HAMMER := 50
const COST_BOMB := 120
const COST_REROLL := 75
const COST_REVIVE := 200

enum JokerType { NONE, HAMMER, BOMB }
var active_joker := JokerType.NONE
var joker_bar: HBoxContainer
var hammer_btn: Button
var bomb_btn: Button
var reroll_btn: Button

# BEYAZ ROZET SAYAC ETİKETLERİ
var hammer_badge: Label
var bomb_badge: Label
var reroll_badge: Label

# PANELLER VE BUTONLAR
var start_menu_panel: Control
var settings_panel: Control
var quests_panel: Control
var help_panel: Control
var in_game_settings_btn: Button
var in_game_quests_btn: Button
var in_game_help_btn: Button

# YENİ AYAR DEĞİŞKENLERİ
var master_volume := 1.0
var music_volume := 1.0
var is_dark_mode := true

var main_bg: ColorRect
var settings_vbox: VBoxContainer
var volume_label: Label
var volume_slider: HSlider
var music_label: Label
var music_slider: HSlider
var theme_btn: Button
var credits_btn: Button
var credits_panel: Control
var restart_btn: Button
var main_menu_btn: Button
var settings_card: Panel

# GÜNLÜK GÖREV SİSTEMİ
var last_quest_date := ""
var daily_quests := []
var quest_list_container: VBoxContainer

var all_quest_templates := [
	{"id": "place_blocks", "title": "100 Blok Yerleştir", "target": 100, "reward": 80},
	{"id": "clear_lines", "title": "15 Çizgi Patlat", "target": 15, "reward": 100},
	{"id": "do_streaks", "title": "3 Kez Streak Yap", "target": 3, "reward": 120},
	{"id": "reach_score", "title": "Tek Oyunda 500 Skor Yap", "target": 500, "reward": 150},
	{"id": "use_jokers", "title": "2 Kez Joker Kullan", "target": 2, "reward": 90}
]

var studio_name_text := "BONET GAMES"

func _ready() -> void:
	randomize()
	mouse_filter = Control.MOUSE_FILTER_PASS

	# ANA ARKA PLAN (Tema değişimleri için bunu kullanıyoruz)
	main_bg = ColorRect.new()
	main_bg.anchor_right = 1.0
	main_bg.anchor_bottom = 1.0
	main_bg.mouse_filter = ColorRect.MOUSE_FILTER_IGNORE
	add_child(main_bg)
	
	combo_timer = Timer.new()
	combo_timer.wait_time = 8.0
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timeout)
	add_child(combo_timer)

	load_save_data()
	_apply_theme()
	_check_and_reset_daily_quests()

	var title = Label.new()
	title.text = "BLOCK BLAST"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("f5f5f5"))
	title.position = Vector2(0, 20)
	title.size = Vector2(720, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	# SAĞ ÜST İKON BUTONLARI
	in_game_settings_btn = _create_icon_button("⚙", Vector2(640, 20))
	in_game_settings_btn.pressed.connect(func(): _open_settings(true))
	add_child(in_game_settings_btn)

	in_game_quests_btn = _create_icon_button("🎯", Vector2(575, 20))
	in_game_quests_btn.pressed.connect(func(): quests_panel.visible = true)
	add_child(in_game_quests_btn)

	in_game_help_btn = _create_icon_button("❓", Vector2(510, 20))
	in_game_help_btn.pressed.connect(func(): help_panel.visible = true)
	add_child(in_game_help_btn)

	# SKOR, REKOR VE ALTIN PANELLERİ
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	score_label.position = Vector2(35, 85)
	add_child(score_label)

	high_score_label = Label.new()
	high_score_label.text = "Best: %d" % high_score
	high_score_label.add_theme_font_size_override("font_size", 24)
	high_score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	high_score_label.position = Vector2(215, 85)
	add_child(high_score_label)

	gold_label = Label.new()
	gold_label.text = "🪙 %d" % gold_amount
	gold_label.add_theme_font_size_override("font_size", 26)
	gold_label.add_theme_color_override("font_color", Color("f1c40f"))
	gold_label.position = Vector2(395, 85)
	add_child(gold_label)

	_apply_volume(master_volume)
	_apply_music_volume(music_volume)

	grid = GridView.new()
	grid.position = Vector2(64, 150)
	grid.piece_placed.connect(_on_piece_placed)
	grid.cell_clicked_for_joker.connect(_on_cell_clicked_for_joker)
	add_child(grid)

	_build_joker_bar()

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

	quests_panel = Control.new()
	quests_panel.anchor_right = 1.0
	quests_panel.anchor_bottom = 1.0
	quests_panel.z_index = 170
	quests_panel.visible = false
	add_child(quests_panel)
	_build_quests_panel()

	help_panel = Control.new()
	help_panel.anchor_right = 1.0
	help_panel.anchor_bottom = 1.0
	help_panel.z_index = 180
	help_panel.visible = false
	add_child(help_panel)
	_build_help_panel()
	
	_build_credits_panel()

	_show_splash_screen()

# --- TEMA VE SES FONKSİYONLARI ---
func _apply_theme() -> void:
	if is_dark_mode:
		main_bg.color = Color("1a1a2e")
		if theme_btn: theme_btn.text = "🌙 KARANLIK MOD"
	else:
		main_bg.color = Color("e0e6ed")
		if theme_btn: theme_btn.text = "☀️ AYDINLIK MOD"

func _toggle_theme() -> void:
	is_dark_mode = !is_dark_mode
	_apply_theme()
	save_save_data()

func _on_volume_changed(val: float) -> void:
	master_volume = val
	volume_label.text = "EFEKT SESİ: %d%%" % int(master_volume * 100)
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

func _on_music_changed(val: float) -> void:
	music_volume = val
	music_label.text = "MÜZİK: %d%%" % int(music_volume * 100)
	_apply_music_volume(music_volume)
	save_save_data()

func _apply_music_volume(val: float) -> void:
	# DİKKAT: Editor altındaki Audio kısmından "Music" bus'ını eklemiş olman gerekiyor!
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index >= 0:
		if val <= 0.001:
			AudioServer.set_bus_mute(bus_index, true)
		else:
			AudioServer.set_bus_mute(bus_index, false)
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(val))

func _create_icon_button(icon_text: String, pos: Vector2) -> Button:
	var btn = Button.new()
	btn.text = icon_text
	btn.position = pos
	btn.custom_minimum_size = Vector2(55, 55)
	btn.add_theme_font_size_override("font_size", 26)
	btn.add_theme_color_override("font_color", Color("ffffff"))
	btn.z_index = 80

	var style = StyleBoxFlat.new()
	style.bg_color = Color("3a3b5c")
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	var hover = style.duplicate()
	hover.bg_color = Color("2d2e47")

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	return btn

func _build_joker_bar() -> void:
	joker_bar = HBoxContainer.new()
	joker_bar.position = Vector2(40, 810)
	joker_bar.custom_minimum_size = Vector2(640, 70)
	joker_bar.add_theme_constant_override("separation", 20)
	add_child(joker_bar)

	hammer_btn = _create_joker_button("🔨", Color("e67e22"))
	hammer_btn.pressed.connect(func(): _on_joker_pressed(JokerType.HAMMER))
	joker_bar.add_child(hammer_btn)
	hammer_badge = _add_badge_to_button(hammer_btn)

	bomb_btn = _create_joker_button("💣", Color("e74c3c"))
	bomb_btn.pressed.connect(func(): _on_joker_pressed(JokerType.BOMB))
	joker_bar.add_child(bomb_btn)
	bomb_badge = _add_badge_to_button(bomb_btn)

	reroll_btn = _create_joker_button("🔄", Color("9b59b6"))
	reroll_btn.pressed.connect(_on_reroll_pressed)
	joker_bar.add_child(reroll_btn)
	reroll_badge = _add_badge_to_button(reroll_btn)

	_update_joker_labels()

func _add_badge_to_button(parent_btn: Button) -> Label:
	var badge = Label.new()
	badge.custom_minimum_size = Vector2(36, 28)
	badge.position = Vector2(150, -8)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 16)
	badge.add_theme_color_override("font_color", Color("1a1a2e"))
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("ffffff")
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("1a1a2e")
	
	badge.add_theme_stylebox_override("normal", style)
	parent_btn.add_child(badge)
	return badge

func _update_joker_labels() -> void:
	hammer_badge.text = str(hammer_count)
	hammer_btn.text = "🔨" if hammer_count > 0 else "+ %d🪙" % COST_HAMMER

	bomb_badge.text = str(bomb_count)
	bomb_btn.text = "💣" if bomb_count > 0 else "+ %d🪙" % COST_BOMB

	reroll_badge.text = str(reroll_count)
	reroll_btn.text = "🔄" if reroll_count > 0 else "+ %d🪙" % COST_REROLL

func _create_joker_button(text: String, base_color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 65)
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color.WHITE)

	var style = StyleBoxFlat.new()
	style.bg_color = base_color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_bottom = 5
	style.border_color = base_color.darkened(0.3)

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	return btn

func _on_joker_pressed(type: JokerType) -> void:
	if type == JokerType.HAMMER:
		if hammer_count <= 0:
			_try_buy_joker(JokerType.HAMMER)
			return
	elif type == JokerType.BOMB:
		if bomb_count <= 0:
			_try_buy_joker(JokerType.BOMB)
			return

	if active_joker == type:
		active_joker = JokerType.NONE
	else:
		active_joker = type
	_update_joker_buttons_visual()

func _try_buy_joker(type: JokerType) -> void:
	var cost := 0
	if type == JokerType.HAMMER: cost = COST_HAMMER
	elif type == JokerType.BOMB: cost = COST_BOMB
	elif type == JokerType.NONE: cost = COST_REROLL

	if gold_amount >= cost:
		gold_amount -= cost
		if type == JokerType.HAMMER: hammer_count += 1
		elif type == JokerType.BOMB: bomb_count += 1
		elif type == JokerType.NONE: reroll_count += 1
		
		_update_gold_display()
		_update_joker_labels()
		save_save_data()
		Input.vibrate_handheld(100)
	else:
		_show_not_enough_gold_anim()

func _update_joker_buttons_visual() -> void:
	hammer_btn.modulate = Color(1.6, 1.6, 1.6) if active_joker == JokerType.HAMMER else Color.WHITE
	bomb_btn.modulate = Color(1.6, 1.6, 1.6) if active_joker == JokerType.BOMB else Color.WHITE

func _on_cell_clicked_for_joker(cell_pos: Vector2i) -> void:
	if active_joker == JokerType.NONE:
		return

	var success := false

	if active_joker == JokerType.HAMMER and hammer_count > 0:
		if grid.use_hammer(cell_pos):
			hammer_count -= 1
			success = true
	elif active_joker == JokerType.BOMB and bomb_count > 0:
		if grid.use_bomb(cell_pos):
			bomb_count -= 1
			success = true

	if success:
		_update_joker_labels()
		_update_quest_progress("use_jokers", 1)
		save_save_data()
		Input.vibrate_handheld(150)
		active_joker = JokerType.NONE
		_update_joker_buttons_visual()
		_check_game_over()

func _on_reroll_pressed() -> void:
	if reroll_count > 0:
		reroll_count -= 1
		_update_joker_labels()
		_update_quest_progress("use_jokers", 1)
		save_save_data()
		Input.vibrate_handheld(80)
		_new_tray()
	else:
		_try_buy_joker(JokerType.NONE)

func _on_piece_placed(rows_cleared: int, cols_cleared: int, cells_placed: int) -> void:
	var total_cleared = rows_cleared + cols_cleared
	
	score += (cells_placed * 10)
	_update_quest_progress("place_blocks", cells_placed)

	if total_cleared > 0:
		streak_count += 1
		_update_quest_progress("clear_lines", total_cleared)
		
		if streak_count >= 2:
			_update_quest_progress("do_streaks", 1)
		
		var added_combo = total_cleared * 2
		combo_count += added_combo
		combo_timer.start()
		
		var earned_gold = (total_cleared * 15) + (streak_count * 10)
		gold_amount += earned_gold
		_update_gold_display()
		
		var base_clear_score = total_cleared * 250
		score += (base_clear_score * max(1, combo_count)) + (streak_count * 50)
		
		if AudioManager.has_node("SfxBlast"):
			var blast_sfx = AudioManager.get_node("SfxBlast")
			blast_sfx.pitch_scale = min(1.0 + (combo_count + streak_count - 2) * 0.12, 2.2)
			blast_sfx.play()
		
		var vibration_time = min(100 + (combo_count * 30) + (streak_count * 20), 300)
		Input.vibrate_handheld(vibration_time)
		
		var random_offset = Vector2(randf_range(100, 412), randf_range(100, 412))
		var pop_pos = grid.global_position + random_offset
		
		if streak_count >= 2:
			_show_combo_popup("STREAK x%d! (+%d🪙)" % [streak_count, earned_gold], pop_pos, true)
		elif combo_count >= 1:
			_show_combo_popup("COMBO x%d! (+%d🪙)" % [combo_count, earned_gold], pop_pos, false)
			
		if _is_board_completely_empty():
			score += 500
			gold_amount += 50
			_update_gold_display()
			_show_combo_popup("ALL CLEAR! +500 PTS (+50🪙)", grid.global_position + Vector2(256, 256), true)
			Input.vibrate_handheld(400)
	else:
		streak_count = 0
		Input.vibrate_handheld(40)

	score_label.text = "Score: %d" % score
	_update_quest_progress("reach_score", score, true)
	
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

func _is_board_completely_empty() -> bool:
	if not grid or not ("grid_data" in grid): return false
	for r in range(grid.GRID_SIZE):
		for c in range(grid.GRID_SIZE):
			if grid.grid_data[r][c] != null:
				return false
	return true

func load_save_data() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		high_score = config.get_value("game", "high_score", 0)
		gold_amount = config.get_value("game", "gold_amount", 100)
		master_volume = config.get_value("game", "master_volume", 1.0)
		music_volume = config.get_value("game", "music_volume", 1.0)
		is_dark_mode = config.get_value("game", "is_dark_mode", true)
		hammer_count = config.get_value("jokers", "hammer_count", 3)
		bomb_count = config.get_value("jokers", "bomb_count", 1)
		reroll_count = config.get_value("jokers", "reroll_count", 2)
		last_quest_date = config.get_value("quests", "last_quest_date", "")
		daily_quests = config.get_value("quests", "daily_quests", [])
	else:
		high_score = 0
		gold_amount = 100
		master_volume = 1.0
		music_volume = 1.0
		is_dark_mode = true
		hammer_count = 3
		bomb_count = 1
		reroll_count = 2
		last_quest_date = ""
		daily_quests = []

func save_save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.set_value("game", "gold_amount", gold_amount)
	config.set_value("game", "master_volume", master_volume)
	config.set_value("game", "music_volume", music_volume)
	config.set_value("game", "is_dark_mode", is_dark_mode)
	config.set_value("jokers", "hammer_count", hammer_count)
	config.set_value("jokers", "bomb_count", bomb_count)
	config.set_value("jokers", "reroll_count", reroll_count)
	config.set_value("quests", "last_quest_date", last_quest_date)
	config.set_value("quests", "daily_quests", daily_quests)
	config.save(SAVE_PATH)

func _build_help_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	help_panel.add_child(dim)

	var card = Panel.new()
	card.position = Vector2(50, 180)
	card.custom_minimum_size = Vector2(620, 680)
	
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
	card.add_theme_stylebox_override("panel", card_style)
	help_panel.add_child(card)

	var h_title = Label.new()
	h_title.text = "❓ NASIL OYNANIR & JOKERLER"
	h_title.add_theme_font_size_override("font_size", 30)
	h_title.add_theme_color_override("font_color", Color("ffffff"))
	h_title.position = Vector2(0, 25)
	h_title.size = Vector2(620, 45)
	h_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(h_title)

	var content = VBoxContainer.new()
	content.position = Vector2(35, 85)
	content.custom_minimum_size = Vector2(550, 500)
	content.add_theme_constant_override("separation", 22)
	card.add_child(content)

	_add_help_item(content, "🎮 TEMEL AMAÇ", "Aşağıdaki parçaları ızgaraya sürükle. Yatay veya dikey hatları tamamen doldurarak patlat ve puan topla!")
	_add_help_item(content, "🔨 ÇEKİÇ JOKERİ (%d🪙)" % COST_HAMMER, "Butona basıp ızgaradaki tek bir kareye tıkla. O blok anında patlar!")
	_add_help_item(content, "💣 BOMBA JOKERİ (%d🪙)" % COST_BOMB, "Butona basıp ızgarada bir yere tıkla. Etrafındaki 3x3 geniş alanı patlatır!")
	_add_help_item(content, "🔄 YENİLE JOKERİ (%d🪙)" % COST_REROLL, "Tepsideki 3 parçayı beğenmediğinde bas. Sana yepyeni 3 parça getirir!")

	var close_btn = Button.new()
	close_btn.text = "ANLADIM"
	close_btn.position = Vector2(210, 600)
	close_btn.custom_minimum_size = Vector2(200, 50)
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color("ffffff"))
	close_btn.pressed.connect(func(): help_panel.visible = false)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	card.add_child(close_btn)

func _add_help_item(container: VBoxContainer, title_text: String, desc_text: String) -> void:
	var box = VBoxContainer.new()
	
	var t = Label.new()
	t.text = title_text
	t.add_theme_font_size_override("font_size", 20)
	t.add_theme_color_override("font_color", Color("f1c40f"))
	box.add_child(t)

	var d = Label.new()
	d.text = desc_text
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_theme_font_size_override("font_size", 16)
	d.add_theme_color_override("font_color", Color("dcdde1"))
	box.add_child(d)

	container.add_child(box)

func _show_quest_complete_toast(quest_title: String) -> void:
	Input.vibrate_handheld(250)
	
	var toast = Panel.new()
	toast.position = Vector2(110, -80)
	toast.custom_minimum_size = Vector2(500, 65)
	toast.z_index = 200
	
	var t_style = StyleBoxFlat.new()
	t_style.bg_color = Color("2ed573")
	t_style.corner_radius_top_left = 16
	t_style.corner_radius_top_right = 16
	t_style.corner_radius_bottom_left = 16
	t_style.corner_radius_bottom_right = 16
	t_style.border_width_bottom = 4
	t_style.border_color = Color("26af5f")
	toast.add_theme_stylebox_override("panel", t_style)
	add_child(toast)

	var lbl = Label.new()
	lbl.text = "🎯 GÖREV TAMAMLANDI!\n%s" % quest_title
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color("ffffff"))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.position = Vector2(0, 0)
	lbl.size = Vector2(500, 65)
	toast.add_child(lbl)

	var tween = create_tween()
	tween.tween_property(toast, "position:y", 25.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.2)
	tween.tween_property(toast, "position:y", -80.0, 0.3).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(toast.queue_free)

func _check_and_reset_daily_quests() -> void:
	var today_dict = Time.get_date_dict_from_system()
	var today_str = "%d-%d-%d" % [today_dict["year"], today_dict["month"], today_dict["day"]]
	
	if last_quest_date != today_str or daily_quests.size() == 0:
		last_quest_date = today_str
		daily_quests.clear()
		
		var pool = all_quest_templates.duplicate(true)
		pool.shuffle()
		
		for i in range(min(3, pool.size())):
			var q = pool[i]
			q["current"] = 0
			q["claimed"] = false
			daily_quests.append(q)
			
		save_save_data()

func _update_quest_progress(quest_id: String, amount: int = 1, is_absolute: bool = false) -> void:
	var updated := false
	for q in daily_quests:
		if q["id"] == quest_id and not q["claimed"]:
			var prev_val = q["current"]
			if is_absolute:
				if amount > q["current"]:
					q["current"] = min(amount, q["target"])
					updated = true
			else:
				q["current"] = min(q["current"] + amount, q["target"])
				updated = true
				
			if prev_val < q["target"] and q["current"] >= q["target"]:
				_show_quest_complete_toast(q["title"])
				
	if updated:
		save_save_data()
		_refresh_quests_ui()

func _build_quests_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	quests_panel.add_child(dim)

	var card = Panel.new()
	card.position = Vector2(60, 220)
	card.custom_minimum_size = Vector2(600, 600)
	
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
	card.add_theme_stylebox_override("panel", card_style)
	quests_panel.add_child(card)

	var q_title = Label.new()
	q_title.text = "🎯 GÜNLÜK GÖREVLER"
	q_title.add_theme_font_size_override("font_size", 34)
	q_title.add_theme_color_override("font_color", Color("ffffff"))
	q_title.position = Vector2(0, 25)
	q_title.size = Vector2(600, 50)
	q_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(q_title)

	quest_list_container = VBoxContainer.new()
	quest_list_container.position = Vector2(40, 90)
	quest_list_container.custom_minimum_size = Vector2(520, 420)
	quest_list_container.add_theme_constant_override("separation", 20)
	card.add_child(quest_list_container)

	var close_btn = Button.new()
	close_btn.text = "KAPAT"
	close_btn.position = Vector2(200, 520)
	close_btn.custom_minimum_size = Vector2(200, 50)
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.add_theme_color_override("font_color", Color("ffffff"))
	close_btn.pressed.connect(func(): quests_panel.visible = false)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	card.add_child(close_btn)

	_refresh_quests_ui()

func _refresh_quests_ui() -> void:
	if not quest_list_container: return
	
	for child in quest_list_container.get_children():
		child.queue_free()

	for q in daily_quests:
		var row = Panel.new()
		row.custom_minimum_size = Vector2(520, 110)
		
		var r_style = StyleBoxFlat.new()
		r_style.bg_color = Color("1a1a2e")
		r_style.corner_radius_top_left = 16
		r_style.corner_radius_top_right = 16
		r_style.corner_radius_bottom_left = 16
		r_style.corner_radius_bottom_right = 16
		row.add_theme_stylebox_override("panel", r_style)

		var title_lbl = Label.new()
		title_lbl.text = q["title"]
		title_lbl.add_theme_font_size_override("font_size", 20)
		title_lbl.add_theme_color_override("font_color", Color("ffffff"))
		title_lbl.position = Vector2(20, 15)
		row.add_child(title_lbl)

		var prog_lbl = Label.new()
		prog_lbl.text = "%d / %d" % [q["current"], q["target"]]
		prog_lbl.add_theme_font_size_override("font_size", 18)
		prog_lbl.add_theme_color_override("font_color", Color("aaaaff"))
		prog_lbl.position = Vector2(20, 50)
		row.add_child(prog_lbl)

		var claim_btn = Button.new()
		claim_btn.position = Vector2(340, 25)
		claim_btn.custom_minimum_size = Vector2(160, 60)
		claim_btn.add_theme_font_size_override("font_size", 18)

		var btn_style = StyleBoxFlat.new()
		btn_style.corner_radius_top_left = 12
		btn_style.corner_radius_top_right = 12
		btn_style.corner_radius_bottom_left = 12
		btn_style.corner_radius_bottom_right = 12

		if q["claimed"]:
			claim_btn.text = "TAMAMLANDI"
			btn_style.bg_color = Color("555555")
			claim_btn.disabled = true
		elif q["current"] >= q["target"]:
			claim_btn.text = "AL (+%d🪙)" % q["reward"]
			btn_style.bg_color = Color("f1c40f")
			claim_btn.add_theme_color_override("font_color", Color("000000"))
			claim_btn.pressed.connect(func(): _claim_quest_reward(q))
		else:
			claim_btn.text = "+%d🪙" % q["reward"]
			btn_style.bg_color = Color("3a3b5c")
			claim_btn.disabled = true

		claim_btn.add_theme_stylebox_override("normal", btn_style)
		claim_btn.add_theme_stylebox_override("disabled", btn_style)
		row.add_child(claim_btn)

		quest_list_container.add_child(row)

func _claim_quest_reward(quest: Dictionary) -> void:
	quest["claimed"] = true
	gold_amount += quest["reward"]
	_update_gold_display()
	save_save_data()
	Input.vibrate_handheld(150)
	_refresh_quests_ui()

func _show_not_enough_gold_anim() -> void:
	Input.vibrate_handheld(200)
	var tween = create_tween()
	tween.tween_property(gold_label, "modulate", Color.RED, 0.15)
	tween.tween_property(gold_label, "modulate", Color.WHITE, 0.15)

func _update_gold_display() -> void:
	gold_label.text = "🪙 %d" % gold_amount

func _show_splash_screen() -> void:
	splash_panel = ColorRect.new()
	splash_panel.color = Color("0d0d14")
	splash_panel.anchor_right = 1.0
	splash_panel.anchor_bottom = 1.0
	splash_panel.z_index = 200
	add_child(splash_panel)

	var st_label = Label.new()
	st_label.text = studio_name_text
	st_label.add_theme_font_size_override("font_size", 52)
	st_label.add_theme_color_override("font_color", Color("ffffff"))
	st_label.position = Vector2(0, 560)
	st_label.size = Vector2(720, 80)
	st_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	st_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	st_label.pivot_offset = Vector2(360, 40)
	st_label.modulate.a = 0.0
	st_label.scale = Vector2(0.8, 0.8)
	splash_panel.add_child(st_label)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(st_label, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(st_label, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var seq = create_tween()
	seq.tween_interval(1.4)
	seq.tween_property(splash_panel, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	seq.tween_callback(splash_panel.queue_free)

func _show_combo_popup(text: String, spawn_pos: Vector2, is_streak: bool = false) -> void:
	var pop_label = Label.new()
	pop_label.text = text
	pop_label.add_theme_font_size_override("font_size", 42 if is_streak else 38)
	
	if is_streak:
		pop_label.add_theme_color_override("font_color", Color("ff4757"))
	else:
		pop_label.add_theme_color_override("font_color", Color("ff9f43"))
		
	pop_label.add_theme_color_override("font_outline_color", Color("000000"))
	pop_label.add_theme_constant_override("outline_size", 8 if is_streak else 6)
	
	pop_label.custom_minimum_size = Vector2(300, 60)
	pop_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pop_label.pivot_offset = Vector2(150, 30)
	pop_label.position = spawn_pos - Vector2(150, 30)
	pop_label.z_index = 90
	add_child(pop_label)

	pop_label.scale = Vector2(0.2, 0.2)
	pop_label.modulate.a = 1.0

	var tween = create_tween().set_parallel(true)
	tween.tween_property(pop_label, "scale", Vector2(1.35 if is_streak else 1.2, 1.35 if is_streak else 1.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(pop_label, "position:y", pop_label.position.y - 70.0, 0.65).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(pop_label, "modulate:a", 0.0, 0.65).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_callback(pop_label.queue_free)

func _build_start_menu_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color("1a1a2e", 0.95)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	start_menu_panel.add_child(dim)

	var title_label = Label.new()
	title_label.text = "BLOCK BLAST"
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", Color("ffffff"))
	title_label.position = Vector2(0, 320)
	title_label.size = Vector2(720, 70)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_menu_panel.add_child(title_label)

	var menu_best_label = Label.new()
	menu_best_label.text = "BEST SCORE: %d" % high_score
	menu_best_label.add_theme_font_size_override("font_size", 32)
	menu_best_label.add_theme_color_override("font_color", Color("f1c40f"))
	menu_best_label.position = Vector2(0, 400)
	menu_best_label.size = Vector2(720, 50)
	menu_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_menu_panel.add_child(menu_best_label)

	var play_btn = Button.new()
	play_btn.text = "PLAY"
	play_btn.position = Vector2(210, 490)
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

	var q_btn = Button.new()
	q_btn.text = "🎯 GÜNLÜK GÖREVLER"
	q_btn.position = Vector2(210, 595)
	q_btn.custom_minimum_size = Vector2(300, 65)
	q_btn.add_theme_font_size_override("font_size", 22)
	q_btn.add_theme_color_override("font_color", Color("ffffff"))
	q_btn.pressed.connect(func(): quests_panel.visible = true)

	var q_style = StyleBoxFlat.new()
	q_style.bg_color = Color("e67e22")
	q_style.corner_radius_top_left = 20
	q_style.corner_radius_top_right = 20
	q_style.corner_radius_bottom_left = 20
	q_style.corner_radius_bottom_right = 20
	q_style.border_width_bottom = 5
	q_style.border_color = Color("d35400")

	q_btn.add_theme_stylebox_override("normal", q_style)
	q_btn.add_theme_stylebox_override("hover", q_style)
	q_btn.add_theme_stylebox_override("pressed", q_style)
	start_menu_panel.add_child(q_btn)

	var settings_btn = Button.new()
	settings_btn.text = "⚙ AYARLAR"
	settings_btn.position = Vector2(240, 680)
	settings_btn.custom_minimum_size = Vector2(240, 60)
	settings_btn.add_theme_font_size_override("font_size", 24)
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

	settings_btn.add_theme_stylebox_override("normal", set_style)
	settings_btn.add_theme_stylebox_override("hover", set_style)
	settings_btn.add_theme_stylebox_override("pressed", set_style)
	start_menu_panel.add_child(settings_btn)

# --- YENİLENMİŞ AYARLAR PANELİ (VBoxContainer ile) ---
func _build_settings_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	settings_panel.add_child(dim)

	settings_card = Panel.new()
	settings_card.custom_minimum_size = Vector2(520, 650)
	settings_card.position = Vector2(100, 200)
	
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
	set_title.position = Vector2(0, 20)
	set_title.size = Vector2(520, 50)
	set_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_card.add_child(set_title)

	settings_vbox = VBoxContainer.new()
	settings_vbox.position = Vector2(60, 90)
	settings_vbox.custom_minimum_size = Vector2(400, 500)
	settings_vbox.add_theme_constant_override("separation", 15)
	settings_card.add_child(settings_vbox)

	# SFX
	volume_label = Label.new()
	volume_label.text = "EFEKT SESİ: %d%%" % int(master_volume * 100)
	volume_label.add_theme_font_size_override("font_size", 20)
	volume_label.add_theme_color_override("font_color", Color("f1c40f"))
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_vbox.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = master_volume
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_vbox.add_child(volume_slider)

	# MUSIC
	music_label = Label.new()
	music_label.text = "MÜZİK: %d%%" % int(music_volume * 100)
	music_label.add_theme_font_size_override("font_size", 20)
	music_label.add_theme_color_override("font_color", Color("f1c40f"))
	music_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_vbox.add_child(music_label)

	music_slider = HSlider.new()
	music_slider.min_value = 0.0
	music_slider.max_value = 1.0
	music_slider.step = 0.01
	music_slider.value = music_volume
	music_slider.value_changed.connect(_on_music_changed)
	settings_vbox.add_child(music_slider)

	var space = Control.new()
	space.custom_minimum_size = Vector2(0, 10)
	settings_vbox.add_child(space)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("3a3b5c")
	btn_style.corner_radius_top_left = 16
	btn_style.corner_radius_top_right = 16
	btn_style.corner_radius_bottom_left = 16
	btn_style.corner_radius_bottom_right = 16
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color("2d2e47")

	theme_btn = Button.new()
	theme_btn.custom_minimum_size = Vector2(400, 50)
	theme_btn.add_theme_font_size_override("font_size", 20)
	theme_btn.add_theme_stylebox_override("normal", btn_style)
	theme_btn.pressed.connect(_toggle_theme)
	settings_vbox.add_child(theme_btn)

	credits_btn = Button.new()
	credits_btn.text = "ℹ️ YAPIMCILAR (CREDITS)"
	credits_btn.custom_minimum_size = Vector2(400, 50)
	credits_btn.add_theme_font_size_override("font_size", 20)
	credits_btn.add_theme_stylebox_override("normal", btn_style)
	credits_btn.pressed.connect(func(): credits_panel.visible = true)
	settings_vbox.add_child(credits_btn)

	restart_btn = Button.new()
	restart_btn.text = "🔄 YENİDEN BAŞLAT"
	restart_btn.custom_minimum_size = Vector2(400, 50)
	restart_btn.add_theme_font_size_override("font_size", 20)
	restart_btn.add_theme_stylebox_override("normal", btn_style)
	restart_btn.pressed.connect(_on_settings_restart_pressed)
	settings_vbox.add_child(restart_btn)

	main_menu_btn = Button.new()
	main_menu_btn.text = "🏠 ANA MENÜ"
	main_menu_btn.custom_minimum_size = Vector2(400, 50)
	main_menu_btn.add_theme_font_size_override("font_size", 20)
	main_menu_btn.add_theme_stylebox_override("normal", btn_style)
	main_menu_btn.pressed.connect(_on_settings_menu_pressed)
	settings_vbox.add_child(main_menu_btn)

	var close_btn = Button.new()
	close_btn.text = "KAPAT"
	close_btn.custom_minimum_size = Vector2(400, 50)
	close_btn.add_theme_font_size_override("font_size", 20)
	
	var close_style = btn_style.duplicate()
	close_style.bg_color = Color("2ed573")
	close_style.border_color = Color("26af5f")
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.pressed.connect(_close_settings)
	settings_vbox.add_child(close_btn)

func _open_settings(is_in_game: bool = false) -> void:
	if is_in_game:
		restart_btn.visible = true
		main_menu_btn.visible = true
		settings_card.custom_minimum_size = Vector2(520, 580)
		settings_card.position = Vector2(100, 200)
	else:
		restart_btn.visible = false
		main_menu_btn.visible = false
		settings_card.custom_minimum_size = Vector2(520, 450)
		settings_card.position = Vector2(100, 250)
		
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

# --- YAPIMCILAR (CREDITS) PANELİ ---
func _build_credits_panel() -> void:
	credits_panel = Control.new()
	credits_panel.anchor_right = 1.0
	credits_panel.anchor_bottom = 1.0
	credits_panel.z_index = 190
	credits_panel.visible = false
	add_child(credits_panel)

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.95)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	credits_panel.add_child(dim)

	var title = Label.new()
	title.text = "BONET GAMES"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("f1c40f"))
	title.position = Vector2(0, 300)
	title.size = Vector2(720, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_panel.add_child(title)

	var desc = Label.new()
	desc.text = "Geliştirici: Bonet Games\n\nVersiyon: 1.0.0\n\nOynadığınız için teşekkürler!"
	desc.add_theme_font_size_override("font_size", 24)
	desc.add_theme_color_override("font_color", Color("ffffff"))
	desc.position = Vector2(0, 400)
	desc.size = Vector2(720, 150)
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_panel.add_child(desc)

	var close_btn = Button.new()
	close_btn.text = "GERİ DÖN"
	close_btn.position = Vector2(210, 650)
	close_btn.custom_minimum_size = Vector2(300, 60)
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.pressed.connect(func(): credits_panel.visible = false)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("e74c3c")
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_bottom = 6
	style.border_color = Color("c0392b")
	close_btn.add_theme_stylebox_override("normal", style)
	credits_panel.add_child(close_btn)

func _on_start_game_pressed() -> void:
	if start_menu_panel:
		var tween = create_tween()
		tween.tween_property(start_menu_panel, "modulate:a", 0.0, 0.25)
		tween.tween_callback(func(): start_menu_panel.visible = false)
	_new_tray()

func _on_combo_timeout() -> void:
	combo_count = 0

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
	label.position = Vector2(0, 440)
	label.size = Vector2(720, 70)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(label)

	final_score_label = Label.new()
	final_score_label.add_theme_font_size_override("font_size", 36)
	final_score_label.add_theme_color_override("font_color", Color("ffa502"))
	final_score_label.position = Vector2(0, 520)
	final_score_label.size = Vector2(720, 50)
	final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(final_score_label)

	revive_btn = Button.new()
	revive_btn.text = "❤️ DEVAM ET (%d🪙)" % COST_REVIVE
	revive_btn.position = Vector2(180, 600)
	revive_btn.custom_minimum_size = Vector2(360, 65)
	revive_btn.add_theme_font_size_override("font_size", 24)
	revive_btn.add_theme_color_override("font_color", Color("ffffff"))
	revive_btn.pressed.connect(_on_revive_pressed)

	var rev_style = StyleBoxFlat.new()
	rev_style.bg_color = Color("ff4757")
	rev_style.corner_radius_top_left = 20
	rev_style.corner_radius_top_right = 20
	rev_style.corner_radius_bottom_left = 20
	rev_style.corner_radius_bottom_right = 20
	rev_style.border_width_bottom = 6
	rev_style.border_color = Color("d63031")

	revive_btn.add_theme_stylebox_override("normal", rev_style)
	revive_btn.add_theme_stylebox_override("hover", rev_style)
	revive_btn.add_theme_stylebox_override("pressed", rev_style)
	game_over_panel.add_child(revive_btn)

	var btn = Button.new()
	btn.text = "🔄 YENİDEN BAŞLA"
	btn.position = Vector2(210, 685)
	btn.custom_minimum_size = Vector2(300, 60)
	btn.add_theme_font_size_override("font_size", 22)
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

	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_stylebox_override("hover", btn_style)
	btn.add_theme_stylebox_override("pressed", btn_style)
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
	revive_btn.visible = gold_amount >= COST_REVIVE
	game_over_panel.visible = true

func _on_revive_pressed() -> void:
	if gold_amount >= COST_REVIVE:
		gold_amount -= COST_REVIVE
		_update_gold_display()
		save_save_data()
		
		grid.use_bomb(Vector2i(3, 3))
		game_over_panel.visible = false
		Input.vibrate_handheld(200)
		_check_game_over()

func _on_restart() -> void:
	game_over_panel.visible = false
	score = 0
	combo_count = 0
	streak_count = 0
	active_joker = JokerType.NONE
	_update_joker_buttons_visual()
	combo_timer.stop()
	score_label.text = "Score: 0"
	grid.reset_board()
	_new_tray()
