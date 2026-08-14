extends Control

# --- KOLAY / KÜÇÜK PARÇALAR ---
var easy_shapes: Array = [
	[Vector2i(0, 0)],
	[Vector2i(0, 0), Vector2i(1, 0)],
	[Vector2i(0, 0), Vector2i(0, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)],
]

# --- ZOR / BÜYÜK PARÇALAR ---
var hard_shapes: Array = [
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],
	[
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)
	],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)],
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],
	[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2)],
	[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],
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
var master_volume := 1.0
var current_lang := "tr"
var high_score_broken_this_game := false
const SAVE_PATH: String = "user://save_data.cfg"

# ELDEKİ JOKER ADETLERİ
var hammer_count := 3
var bomb_count := 1
var reroll_count := 2

# KOMBO SİSTEMİ
var combo_count := 0
var streak_count := 0
var combo_timer: Timer

var score_label: Label
var high_score_label: Label
var gold_label: Label
var tray_container: Control
var game_over_panel: Control
var game_over_title_label: Label
var final_score_label: Label
var splash_panel: ColorRect
var revive_btn: Button

# JOKER FİYATLARI VE DİNAMİK DEVAM ET MALİYETİ
var COST_HAMMER := 150
var COST_BOMB := 350
var COST_REROLL := 200
var current_revive_cost := 800  # 🔄 Her kullanımda artacak değişken maliyet

enum JokerType { NONE, HAMMER, BOMB }
var active_joker := JokerType.NONE
var joker_bar: HBoxContainer
var hammer_btn: Button
var bomb_btn: Button
var reroll_btn: Button

var hammer_badge: Label
var bomb_badge: Label
var reroll_badge: Label

# PANELLER VE BUTONLAR
var start_menu_panel: Control
var menu_best_label: Label
var start_play_btn: Button
var start_shop_btn: Button
var start_quests_btn: Button
var start_settings_btn: Button

# MAĞAZA BİLEŞENLERİ
var shop_panel: Control
var shop_panel_title: Label
var shop_panel_close_btn: Button
var shop_item_container: VBoxContainer
var shop_gold_label: Label

var settings_panel: Control
var settings_title_label: Label
var quests_panel: Control
var help_panel: Control
var volume_label: Label
var lang_label: Label
var lang_btn: Button
var volume_slider: HSlider
var in_game_settings_btn: Button
var in_game_quests_btn: Button
var in_game_help_btn: Button

var last_quest_date := ""
var daily_quests := []
var quest_list_container: VBoxContainer
var quests_panel_title: Label
var quests_panel_close_btn: Button

var help_title_label: Label
var help_content_container: VBoxContainer
var help_close_btn: Button

var restart_btn: Button
var main_menu_btn: Button
var close_settings_btn: Button
var game_over_restart_btn: Button
var settings_card: Panel

var studio_name_text := "BONET GAMES"

# 🌐 ÇEVİRİ SÖZLÜĞÜ
var tr_data := {
	"score": "Skor: %d",
	"best": "En İyi: %d",
	"best_menu": "EN İYİ SKOR: %d",
	"play": "OYNA",
	"shop": "🛒 MAĞAZA",
	"daily_quests": "🎯 GÜNLÜK GÖREVLER",
	"settings": "⚙ AYARLAR",
	"settings_title": "AYARLAR",
	"volume": "SES DÜZEYİ: %d%%",
	"language": "DİL / LANGUAGE",
	"restart": "🔄 YENİDEN BAŞLAT",
	"main_menu": "🏠 ANA MENÜ",
	"close": "KAPAT",
	"game_over": "OYUN BİTTİ",
	"continue": "❤️ DEVAM ET (%d🪙)",
	"help_title": "❓ NASIL OYNANIR & JOKERLER",
	"help_understand": "ANLADIM",
	"quest_completed": "🎯 GÖREV TAMAMLANDI!",
	"quest_done": "TAMAMLANDI",
	"claim": "AL (+%d🪙)",
	"owned": "Adet: %d",
	"shop_hammer": "🔨 Çekiç Paketi (+1)",
	"shop_bomb": "💣 Bomba Paketi (+1)",
	"shop_reroll": "🔄 Yenile Paketi (+1)",
	"h_aim_t": "🎮 TEMEL AMAÇ",
	"h_aim_d": "Aşağıdaki parçaları ızgaraya sürükle. Yatay veya dikey hatları tamamen doldurarak patlat ve puan topla!",
	"h_hammer_t": "🔨 ÇEKİÇ JOKERİ (%d🪙)",
	"h_hammer_d": "Butona basıp ızgaradaki tek bir kareye tıkla. O blok anında patlar!",
	"h_bomb_t": "💣 BOMBA JOKERİ (%d🪙)",
	"h_bomb_d": "Butona basıp ızgarada bir yere tıkla. Etrafındaki 3x3 geniş alanı patlatır!",
	"h_reroll_t": "🔄 YENİLE JOKERİ (%d🪙)",
	"h_reroll_d": "Tepsideki 3 parçayı beğenmediğinde bas. Sana yepyeni 3 parça getirir!",
	"q_place": "100 Blok Yerleştir",
	"q_clear": "15 Çizgi Patlat",
	"q_streak": "3 Kez Streak Yap",
	"q_score": "Tek Oyunda 500 Skor Yap",
	"q_joker": "2 Kez Joker Kullan"
}

var en_data := {
	"score": "Score: %d",
	"best": "Best: %d",
	"best_menu": "BEST SCORE: %d",
	"play": "PLAY",
	"shop": "🛒 SHOP",
	"daily_quests": "🎯 DAILY QUESTS",
	"settings": "⚙ SETTINGS",
	"settings_title": "SETTINGS",
	"volume": "VOLUME: %d%%",
	"language": "LANGUAGE / DİL",
	"restart": "🔄 RESTART",
	"main_menu": "🏠 MAIN MENU",
	"close": "CLOSE",
	"game_over": "GAME OVER",
	"continue": "❤️ CONTINUE (%d🪙)",
	"help_title": "❓ HOW TO PLAY & JOKERS",
	"help_understand": "GOT IT",
	"quest_completed": "🎯 QUEST COMPLETED!",
	"quest_done": "COMPLETED",
	"claim": "CLAIM (+%d🪙)",
	"owned": "Owned: %d",
	"shop_hammer": "🔨 Hammer Pack (+1)",
	"shop_bomb": "💣 Bomb Pack (+1)",
	"shop_reroll": "🔄 Reroll Pack (+1)",
	"h_aim_t": "🎮 MAIN OBJECTIVE",
	"h_aim_d": "Drag the shapes into the grid. Clear vertical or horizontal lines to score points!",
	"h_hammer_t": "🔨 HAMMER JOKER (%d🪙)",
	"h_hammer_d": "Tap the button and select any single block on the grid to destroy it!",
	"h_bomb_t": "💣 BOMB JOKER (%d🪙)",
	"h_bomb_d": "Tap the button and select a block to blast a 3x3 surrounding area!",
	"h_reroll_t": "🔄 REROLL JOKER (%d🪙)",
	"h_reroll_d": "Don't like the 3 current shapes? Tap to refresh them with new ones!",
	"q_place": "Place 100 Blocks",
	"q_clear": "Clear 15 Lines",
	"q_streak": "Achieve Streak 3 Times",
	"q_score": "Reach 500 Score in a Game",
	"q_joker": "Use 2 Jokers"
}

func t(key: String) -> String:
	var dict = tr_data if current_lang == "tr" else en_data
	return dict.get(key, key)

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

	load_save_data()
	_check_and_reset_daily_quests()

	var title = Label.new()
	
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("f5f5f5"))
	title.position = Vector2(0, 20)
	title.size = Vector2(720, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)

	in_game_settings_btn = _create_icon_button("⚙", Vector2(640, 20))
	in_game_settings_btn.pressed.connect(func(): _open_settings(true))
	add_child(in_game_settings_btn)

	in_game_quests_btn = _create_icon_button("🎯", Vector2(575, 20))
	in_game_quests_btn.pressed.connect(func(): quests_panel.visible = true)
	add_child(in_game_quests_btn)

	in_game_help_btn = _create_icon_button("❓", Vector2(510, 20))
	in_game_help_btn.pressed.connect(func(): help_panel.visible = true)
	add_child(in_game_help_btn)

	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.add_theme_color_override("font_color", Color("e0e0e0"))
	score_label.position = Vector2(35, 85)
	add_child(score_label)

	high_score_label = Label.new()
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

	shop_panel = Control.new()
	shop_panel.anchor_right = 1.0
	shop_panel.anchor_bottom = 1.0
	shop_panel.z_index = 165
	shop_panel.visible = false
	add_child(shop_panel)
	_build_shop_panel()

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

	_update_all_ui_texts()
	_show_splash_screen()

func _update_all_ui_texts() -> void:
	score_label.text = t("score") % score
	high_score_label.text = t("best") % high_score
	
	if menu_best_label: menu_best_label.text = t("best_menu") % high_score
	if start_play_btn: start_play_btn.text = t("play")
	if start_shop_btn: start_shop_btn.text = t("shop")
	if start_quests_btn: start_quests_btn.text = t("daily_quests")
	if start_settings_btn: start_settings_btn.text = t("settings")
	
	if shop_panel_title: shop_panel_title.text = t("shop")
	if shop_panel_close_btn: shop_panel_close_btn.text = t("close")
	if shop_gold_label: shop_gold_label.text = "🪙 %d" % gold_amount
	
	if settings_title_label: settings_title_label.text = t("settings_title")
	if volume_label: volume_label.text = t("volume") % int(master_volume * 100)
	if lang_label: lang_label.text = t("language")
	if lang_btn: lang_btn.text = "🇹🇷 TÜRKÇE" if current_lang == "tr" else "🇬🇧 ENGLISH"
	if restart_btn: restart_btn.text = t("restart")
	if main_menu_btn: main_menu_btn.text = t("main_menu")
	if close_settings_btn: close_settings_btn.text = t("close")
	
	if game_over_title_label: game_over_title_label.text = t("game_over")
	if final_score_label: final_score_label.text = t("score") % score
	if revive_btn: revive_btn.text = t("continue") % current_revive_cost
	if game_over_restart_btn: game_over_restart_btn.text = t("restart")
	
	if quests_panel_title: quests_panel_title.text = t("daily_quests")
	if quests_panel_close_btn: quests_panel_close_btn.text = t("close")
	if help_title_label: help_title_label.text = t("help_title")
	if help_close_btn: help_close_btn.text = t("help_understand")
	
	_refresh_help_panel_content()
	_refresh_quests_ui()
	_refresh_shop_ui()

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
		_refresh_shop_ui()
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

	score_label.text = t("score") % score
	_update_quest_progress("reach_score", score, true)
	
	if score > high_score:
		if not high_score_broken_this_game and high_score > 0:
			high_score_broken_this_game = true
			_show_new_record_popup()
			
		high_score = score
		high_score_label.text = t("best") % high_score
	
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

func _show_new_record_popup() -> void:
	Input.vibrate_handheld(300)
	
	var pop_label = Label.new()
	pop_label.text = "🏆 NEW RECORD! 🏆"
	pop_label.add_theme_font_size_override("font_size", 46)
	pop_label.add_theme_color_override("font_color", Color("f1c40f"))
	pop_label.add_theme_color_override("font_outline_color", Color("000000"))
	pop_label.add_theme_constant_override("outline_size", 8)
	
	pop_label.position = Vector2(0, 400)
	pop_label.size = Vector2(720, 70)
	pop_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pop_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pop_label.pivot_offset = Vector2(360, 35)
	pop_label.z_index = 120
	pop_label.scale = Vector2(0.2, 0.2)
	add_child(pop_label)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(pop_label, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(pop_label, "position:y", 330.0, 0.8).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(pop_label, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(pop_label.queue_free)

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
		current_lang = config.get_value("game", "current_lang", "tr")
		hammer_count = config.get_value("jokers", "hammer_count", 3)
		bomb_count = config.get_value("jokers", "bomb_count", 1)
		reroll_count = config.get_value("jokers", "reroll_count", 2)
		last_quest_date = config.get_value("quests", "last_quest_date", "")
		daily_quests = config.get_value("quests", "daily_quests", [])
	else:
		high_score = 0
		gold_amount = 100
		master_volume = 1.0
		current_lang = "tr"
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
	config.set_value("game", "current_lang", current_lang)
	config.set_value("jokers", "hammer_count", hammer_count)
	config.set_value("jokers", "bomb_count", bomb_count)
	config.set_value("jokers", "reroll_count", reroll_count)
	config.set_value("quests", "last_quest_date", last_quest_date)
	config.set_value("quests", "daily_quests", daily_quests)
	config.save(SAVE_PATH)

# --- 🛒 MAĞAZA (SHOP) PANELİ BİLEŞENİ ---
func _build_shop_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.82)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	shop_panel.add_child(dim)

	var card = Panel.new()
	card.position = Vector2(60, 200)
	card.custom_minimum_size = Vector2(600, 620)
	
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
	card_style.border_color = Color("8e44ad")
	card.add_theme_stylebox_override("panel", card_style)
	shop_panel.add_child(card)

	shop_panel_title = Label.new()
	shop_panel_title.add_theme_font_size_override("font_size", 34)
	shop_panel_title.add_theme_color_override("font_color", Color("ffffff"))
	shop_panel_title.position = Vector2(40, 25)
	shop_panel_title.size = Vector2(250, 50)
	shop_panel_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(shop_panel_title)

	shop_gold_label = Label.new()
	shop_gold_label.text = "🪙 %d" % gold_amount
	shop_gold_label.add_theme_font_size_override("font_size", 28)
	shop_gold_label.add_theme_color_override("font_color", Color("f1c40f"))
	shop_gold_label.position = Vector2(350, 25)
	shop_gold_label.size = Vector2(210, 50)
	shop_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	shop_gold_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(shop_gold_label)

	shop_item_container = VBoxContainer.new()
	shop_item_container.position = Vector2(40, 95)
	shop_item_container.custom_minimum_size = Vector2(520, 430)
	shop_item_container.add_theme_constant_override("separation", 20)
	card.add_child(shop_item_container)

	shop_panel_close_btn = Button.new()
	shop_panel_close_btn.position = Vector2(200, 540)
	shop_panel_close_btn.custom_minimum_size = Vector2(200, 50)
	shop_panel_close_btn.add_theme_font_size_override("font_size", 22)
	shop_panel_close_btn.add_theme_color_override("font_color", Color("ffffff"))
	shop_panel_close_btn.pressed.connect(func(): shop_panel.visible = false)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	shop_panel_close_btn.add_theme_stylebox_override("normal", close_style)
	shop_panel_close_btn.add_theme_stylebox_override("hover", close_style)
	shop_panel_close_btn.add_theme_stylebox_override("pressed", close_style)
	card.add_child(shop_panel_close_btn)

	_refresh_shop_ui()

func _refresh_shop_ui() -> void:
	if shop_gold_label:
		shop_gold_label.text = "🪙 %d" % gold_amount
		
	if not shop_item_container: return
	for child in shop_item_container.get_children(): child.queue_free()

	_add_shop_item(shop_item_container, t("shop_hammer"), COST_HAMMER, hammer_count, JokerType.HAMMER)
	_add_shop_item(shop_item_container, t("shop_bomb"), COST_BOMB, bomb_count, JokerType.BOMB)
	_add_shop_item(shop_item_container, t("shop_reroll"), COST_REROLL, reroll_count, JokerType.NONE)

func _add_shop_item(container: VBoxContainer, item_title: String, cost: int, owned_count: int, type: JokerType) -> void:
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
	title_lbl.text = item_title
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color("ffffff"))
	title_lbl.position = Vector2(20, 20)
	row.add_child(title_lbl)

	var owned_lbl = Label.new()
	owned_lbl.text = t("owned") % owned_count
	owned_lbl.add_theme_font_size_override("font_size", 18)
	owned_lbl.add_theme_color_override("font_color", Color("aaaaff"))
	owned_lbl.position = Vector2(20, 58)
	row.add_child(owned_lbl)

	var buy_btn = Button.new()
	buy_btn.position = Vector2(330, 25)
	buy_btn.custom_minimum_size = Vector2(170, 60)
	buy_btn.text = "%d🪙" % cost
	buy_btn.add_theme_font_size_override("font_size", 20)
	buy_btn.add_theme_color_override("font_color", Color("000000"))
	buy_btn.pressed.connect(func(): _try_buy_joker(type))

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("f1c40f")
	btn_style.corner_radius_top_left = 14
	btn_style.corner_radius_top_right = 14
	btn_style.corner_radius_bottom_left = 14
	btn_style.corner_radius_bottom_right = 14
	btn_style.border_width_bottom = 4
	btn_style.border_color = Color("d4ac0d")

	buy_btn.add_theme_stylebox_override("normal", btn_style)
	buy_btn.add_theme_stylebox_override("hover", btn_style)
	buy_btn.add_theme_stylebox_override("pressed", btn_style)
	row.add_child(buy_btn)

	container.add_child(row)

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

	help_title_label = Label.new()
	help_title_label.add_theme_font_size_override("font_size", 30)
	help_title_label.add_theme_color_override("font_color", Color("ffffff"))
	help_title_label.position = Vector2(0, 25)
	help_title_label.size = Vector2(620, 45)
	help_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(help_title_label)

	help_content_container = VBoxContainer.new()
	help_content_container.position = Vector2(35, 85)
	help_content_container.custom_minimum_size = Vector2(550, 500)
	help_content_container.add_theme_constant_override("separation", 22)
	card.add_child(help_content_container)

	help_close_btn = Button.new()
	help_close_btn.position = Vector2(210, 600)
	help_close_btn.custom_minimum_size = Vector2(200, 50)
	help_close_btn.add_theme_font_size_override("font_size", 22)
	help_close_btn.add_theme_color_override("font_color", Color("ffffff"))
	help_close_btn.pressed.connect(func(): help_panel.visible = false)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	help_close_btn.add_theme_stylebox_override("normal", close_style)
	help_close_btn.add_theme_stylebox_override("hover", close_style)
	help_close_btn.add_theme_stylebox_override("pressed", close_style)
	card.add_child(help_close_btn)

	_refresh_help_panel_content()

func _refresh_help_panel_content() -> void:
	if not help_content_container: return
	for c in help_content_container.get_children(): c.queue_free()
	
	_add_help_item(help_content_container, t("h_aim_t"), t("h_aim_d"))
	_add_help_item(help_content_container, t("h_hammer_t") % COST_HAMMER, t("h_hammer_d"))
	_add_help_item(help_content_container, t("h_bomb_t") % COST_BOMB, t("h_bomb_d"))
	_add_help_item(help_content_container, t("h_reroll_t") % COST_REROLL, t("h_reroll_d"))

func _add_help_item(container: VBoxContainer, title_text: String, desc_text: String) -> void:
	var box = VBoxContainer.new()
	var t_lbl = Label.new()
	t_lbl.text = title_text
	t_lbl.add_theme_font_size_override("font_size", 20)
	t_lbl.add_theme_color_override("font_color", Color("f1c40f"))
	box.add_child(t_lbl)

	var d_lbl = Label.new()
	d_lbl.text = desc_text
	d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d_lbl.add_theme_font_size_override("font_size", 16)
	d_lbl.add_theme_color_override("font_color", Color("dcdde1"))
	box.add_child(d_lbl)

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
	lbl.text = "%s\n%s" % [t("quest_completed"), quest_title]
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
		
		var pool = [
			{"id": "place_blocks", "title_key": "q_place", "target": 100, "reward": 80},
			{"id": "clear_lines", "title_key": "q_clear", "target": 15, "reward": 100},
			{"id": "do_streaks", "title_key": "q_streak", "target": 3, "reward": 120},
			{"id": "reach_score", "title_key": "q_score", "target": 500, "reward": 150},
			{"id": "use_jokers", "title_key": "q_joker", "target": 2, "reward": 90}
		]
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
				_show_quest_complete_toast(t(q.get("title_key", "")))
				
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

	quests_panel_title = Label.new()
	quests_panel_title.add_theme_font_size_override("font_size", 34)
	quests_panel_title.add_theme_color_override("font_color", Color("ffffff"))
	quests_panel_title.position = Vector2(0, 25)
	quests_panel_title.size = Vector2(600, 50)
	quests_panel_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(quests_panel_title)

	quest_list_container = VBoxContainer.new()
	quest_list_container.position = Vector2(40, 90)
	quest_list_container.custom_minimum_size = Vector2(520, 420)
	quest_list_container.add_theme_constant_override("separation", 20)
	card.add_child(quest_list_container)

	quests_panel_close_btn = Button.new()
	quests_panel_close_btn.position = Vector2(200, 520)
	quests_panel_close_btn.custom_minimum_size = Vector2(200, 50)
	quests_panel_close_btn.add_theme_font_size_override("font_size", 22)
	quests_panel_close_btn.add_theme_color_override("font_color", Color("ffffff"))
	quests_panel_close_btn.pressed.connect(func(): quests_panel.visible = false)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	quests_panel_close_btn.add_theme_stylebox_override("normal", close_style)
	quests_panel_close_btn.add_theme_stylebox_override("hover", close_style)
	quests_panel_close_btn.add_theme_stylebox_override("pressed", close_style)
	card.add_child(quests_panel_close_btn)

	_refresh_quests_ui()

func _refresh_quests_ui() -> void:
	if not quest_list_container: return
	for child in quest_list_container.get_children(): child.queue_free()

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
		title_lbl.text = t(q.get("title_key", ""))
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
		claim_btn.add_theme_font_size_override("font_size", 16)

		var btn_style = StyleBoxFlat.new()
		btn_style.corner_radius_top_left = 12
		btn_style.corner_radius_top_right = 12
		btn_style.corner_radius_bottom_left = 12
		btn_style.corner_radius_bottom_right = 12

		if q["claimed"]:
			claim_btn.text = t("quest_done")
			btn_style.bg_color = Color("555555")
			claim_btn.disabled = true
		elif q["current"] >= q["target"]:
			claim_btn.text = t("claim") % q["reward"]
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
	
	if shop_gold_label:
		var shop_tween = create_tween()
		shop_tween.tween_property(shop_gold_label, "modulate", Color.RED, 0.15)
		shop_tween.tween_property(shop_gold_label, "modulate", Color.WHITE, 0.15)

func _update_gold_display() -> void:
	gold_label.text = "🪙 %d" % gold_amount
	if shop_gold_label:
		shop_gold_label.text = "🪙 %d" % gold_amount

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
	
	if is_streak: pop_label.add_theme_color_override("font_color", Color("ff4757"))
	else: pop_label.add_theme_color_override("font_color", Color("ff9f43"))
		
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

# --- 🏠 ANA MENÜ BİLEŞENİ ---
func _build_start_menu_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color("1a1a2e")
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	start_menu_panel.add_child(dim)

	var title_label = Label.new()
	title_label.text = "Color Burst"
	title_label.add_theme_font_size_override("font_size", 54)
	title_label.add_theme_color_override("font_color", Color("ffffff"))
	title_label.position = Vector2(0, 260)
	title_label.size = Vector2(720, 70)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_menu_panel.add_child(title_label)

	menu_best_label = Label.new()
	menu_best_label.add_theme_font_size_override("font_size", 32)
	menu_best_label.add_theme_color_override("font_color", Color("f1c40f"))
	menu_best_label.position = Vector2(0, 335)
	menu_best_label.size = Vector2(720, 50)
	menu_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_menu_panel.add_child(menu_best_label)

	start_play_btn = Button.new()
	start_play_btn.position = Vector2(210, 420)
	start_play_btn.custom_minimum_size = Vector2(300, 75)
	start_play_btn.add_theme_font_size_override("font_size", 34)
	start_play_btn.add_theme_color_override("font_color", Color("ffffff"))
	start_play_btn.pressed.connect(_on_start_game_pressed)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("2ed573")
	btn_style.corner_radius_top_left = 22
	btn_style.corner_radius_top_right = 22
	btn_style.corner_radius_bottom_left = 22
	btn_style.corner_radius_bottom_right = 22
	btn_style.border_width_bottom = 8
	btn_style.border_color = Color("26af5f")

	start_play_btn.add_theme_stylebox_override("normal", btn_style)
	start_play_btn.add_theme_stylebox_override("hover", btn_style)
	start_play_btn.add_theme_stylebox_override("pressed", btn_style)
	start_menu_panel.add_child(start_play_btn)

	start_shop_btn = Button.new()
	start_shop_btn.position = Vector2(210, 515)
	start_shop_btn.custom_minimum_size = Vector2(300, 60)
	start_shop_btn.add_theme_font_size_override("font_size", 22)
	start_shop_btn.add_theme_color_override("font_color", Color("ffffff"))
	start_shop_btn.pressed.connect(func(): shop_panel.visible = true)

	var shop_style = StyleBoxFlat.new()
	shop_style.bg_color = Color("8e44ad")
	shop_style.corner_radius_top_left = 18
	shop_style.corner_radius_top_right = 18
	shop_style.corner_radius_bottom_left = 18
	shop_style.corner_radius_bottom_right = 18
	shop_style.border_width_bottom = 5
	shop_style.border_color = Color("71368a")

	start_shop_btn.add_theme_stylebox_override("normal", shop_style)
	start_shop_btn.add_theme_stylebox_override("hover", shop_style)
	start_shop_btn.add_theme_stylebox_override("pressed", shop_style)
	start_menu_panel.add_child(start_shop_btn)

	start_quests_btn = Button.new()
	start_quests_btn.position = Vector2(210, 590)
	start_quests_btn.custom_minimum_size = Vector2(300, 60)
	start_quests_btn.add_theme_font_size_override("font_size", 22)
	start_quests_btn.add_theme_color_override("font_color", Color("ffffff"))
	start_quests_btn.pressed.connect(func(): quests_panel.visible = true)

	var q_style = StyleBoxFlat.new()
	q_style.bg_color = Color("e67e22")
	q_style.corner_radius_top_left = 18
	q_style.corner_radius_top_right = 18
	q_style.corner_radius_bottom_left = 18
	q_style.corner_radius_bottom_right = 18
	q_style.border_width_bottom = 5
	q_style.border_color = Color("d35400")

	start_quests_btn.add_theme_stylebox_override("normal", q_style)
	start_quests_btn.add_theme_stylebox_override("hover", q_style)
	start_quests_btn.add_theme_stylebox_override("pressed", q_style)
	start_menu_panel.add_child(start_quests_btn)

	start_settings_btn = Button.new()
	start_settings_btn.position = Vector2(240, 665)
	start_settings_btn.custom_minimum_size = Vector2(240, 55)
	start_settings_btn.add_theme_font_size_override("font_size", 22)
	start_settings_btn.add_theme_color_override("font_color", Color("ffffff"))
	start_settings_btn.pressed.connect(func(): _open_settings(false))

	var set_style = StyleBoxFlat.new()
	set_style.bg_color = Color("3a3b5c")
	set_style.corner_radius_top_left = 18
	set_style.corner_radius_top_right = 18
	set_style.corner_radius_bottom_left = 18
	set_style.corner_radius_bottom_right = 18
	set_style.border_width_bottom = 5
	set_style.border_color = Color("2d2e47")

	start_settings_btn.add_theme_stylebox_override("normal", set_style)
	start_settings_btn.add_theme_stylebox_override("hover", set_style)
	start_settings_btn.add_theme_stylebox_override("pressed", set_style)
	start_menu_panel.add_child(start_settings_btn)

func _build_settings_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	settings_panel.add_child(dim)

	settings_card = Panel.new()
	settings_card.position = Vector2(80, 240)
	settings_card.custom_minimum_size = Vector2(560, 500)
	
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

	settings_title_label = Label.new()
	settings_title_label.add_theme_font_size_override("font_size", 38)
	settings_title_label.add_theme_color_override("font_color", Color("ffffff"))
	settings_title_label.position = Vector2(0, 20)
	settings_title_label.size = Vector2(560, 50)
	settings_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_card.add_child(settings_title_label)

	volume_label = Label.new()
	volume_label.add_theme_font_size_override("font_size", 22)
	volume_label.add_theme_color_override("font_color", Color("f1c40f"))
	volume_label.position = Vector2(0, 80)
	volume_label.size = Vector2(560, 30)
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_card.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = master_volume
	volume_slider.position = Vector2(80, 115)
	volume_slider.custom_minimum_size = Vector2(400, 35)
	volume_slider.value_changed.connect(_on_volume_changed)
	settings_card.add_child(volume_slider)

	lang_label = Label.new()
	lang_label.add_theme_font_size_override("font_size", 22)
	lang_label.add_theme_color_override("font_color", Color("f1c40f"))
	lang_label.position = Vector2(0, 165)
	lang_label.size = Vector2(560, 30)
	lang_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_card.add_child(lang_label)

	lang_btn = Button.new()
	lang_btn.position = Vector2(150, 205)
	lang_btn.custom_minimum_size = Vector2(260, 50)
	lang_btn.add_theme_font_size_override("font_size", 22)
	lang_btn.pressed.connect(_toggle_language)
	
	var lang_style = StyleBoxFlat.new()
	lang_style.bg_color = Color("8e44ad")
	lang_style.corner_radius_top_left = 16
	lang_style.corner_radius_top_right = 16
	lang_style.corner_radius_bottom_left = 16
	lang_style.corner_radius_bottom_right = 16
	lang_style.border_width_bottom = 4
	lang_style.border_color = Color("71368a")
	lang_btn.add_theme_stylebox_override("normal", lang_style)
	lang_btn.add_theme_stylebox_override("hover", lang_style)
	lang_btn.add_theme_stylebox_override("pressed", lang_style)
	settings_card.add_child(lang_btn)

	restart_btn = Button.new()
	restart_btn.position = Vector2(130, 275)
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

	main_menu_btn = Button.new()
	main_menu_btn.position = Vector2(130, 345)
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

	close_settings_btn = Button.new()
	close_settings_btn.position = Vector2(180, 420)
	close_settings_btn.custom_minimum_size = Vector2(200, 50)
	close_settings_btn.add_theme_font_size_override("font_size", 22)
	close_settings_btn.add_theme_color_override("font_color", Color("ffffff"))
	close_settings_btn.pressed.connect(_close_settings)

	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color("2ed573")
	close_style.corner_radius_top_left = 16
	close_style.corner_radius_top_right = 16
	close_style.corner_radius_bottom_left = 16
	close_style.corner_radius_bottom_right = 16
	close_style.border_width_bottom = 5
	close_style.border_color = Color("26af5f")

	close_settings_btn.add_theme_stylebox_override("normal", close_style)
	close_settings_btn.add_theme_stylebox_override("hover", close_style)
	close_settings_btn.add_theme_stylebox_override("pressed", close_style)
	settings_card.add_child(close_settings_btn)

func _toggle_language() -> void:
	current_lang = "en" if current_lang == "tr" else "tr"
	save_save_data()
	Input.vibrate_handheld(60)
	_update_all_ui_texts()

func _open_settings(is_in_game: bool = false) -> void:
	if is_in_game:
		restart_btn.visible = true
		main_menu_btn.visible = true
		settings_card.custom_minimum_size = Vector2(560, 500)
		settings_card.position = Vector2(80, 220)
	else:
		restart_btn.visible = false
		main_menu_btn.visible = false
		settings_card.custom_minimum_size = Vector2(560, 350)
		settings_card.position = Vector2(80, 300)
		
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
	volume_label.text = t("volume") % int(master_volume * 100)
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

func _on_combo_timeout() -> void:
	combo_count = 0

func _build_game_over_panel() -> void:
	var dim = ColorRect.new()
	dim.color = Color(0.05, 0.05, 0.1, 0.85)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	game_over_panel.add_child(dim)

	game_over_title_label = Label.new()
	game_over_title_label.add_theme_font_size_override("font_size", 56)
	game_over_title_label.add_theme_color_override("font_color", Color("ff4757"))
	game_over_title_label.position = Vector2(0, 440)
	game_over_title_label.size = Vector2(720, 70)
	game_over_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(game_over_title_label)

	final_score_label = Label.new()
	final_score_label.add_theme_font_size_override("font_size", 36)
	final_score_label.add_theme_color_override("font_color", Color("ffa502"))
	final_score_label.position = Vector2(0, 520)
	final_score_label.size = Vector2(720, 50)
	final_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_panel.add_child(final_score_label)

	revive_btn = Button.new()
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

	game_over_restart_btn = Button.new()
	game_over_restart_btn.position = Vector2(210, 685)
	game_over_restart_btn.custom_minimum_size = Vector2(300, 60)
	game_over_restart_btn.add_theme_font_size_override("font_size", 22)
	game_over_restart_btn.add_theme_color_override("font_color", Color("ffffff"))
	game_over_restart_btn.pressed.connect(_on_restart)
	
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color("2ed573")
	btn_style.corner_radius_top_left = 20
	btn_style.corner_radius_top_right = 20
	btn_style.corner_radius_bottom_left = 20
	btn_style.corner_radius_bottom_right = 20
	btn_style.border_width_bottom = 6
	btn_style.border_color = Color("26af5f")

	game_over_restart_btn.add_theme_stylebox_override("normal", btn_style)
	game_over_restart_btn.add_theme_stylebox_override("hover", btn_style)
	game_over_restart_btn.add_theme_stylebox_override("pressed", btn_style)
	game_over_panel.add_child(game_over_restart_btn)

func _new_tray() -> void:
	for p in tray:
		if is_instance_valid(p):
			p.queue_free()
	tray.clear()

	var slot_width = 720 / 3
	var easy_slot_index = randi() % 3
	
	for i in range(3):
		var shape: Array
		if i == easy_slot_index:
			shape = easy_shapes[randi() % easy_shapes.size()]
		else:
			if randf() < 0.4:
				shape = easy_shapes[randi() % easy_shapes.size()]
			else:
				shape = hard_shapes[randi() % hard_shapes.size()]
				
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
	final_score_label.text = t("score") % score
	revive_btn.text = t("continue") % current_revive_cost # 👈 Buton yazısı güncel maliyetle yenilenir
	revive_btn.visible = gold_amount >= current_revive_cost
	game_over_panel.visible = true

# 🔄 ARTAN DEVAM ET (REVIVE) MANTIĞI
func _on_revive_pressed() -> void:
	if gold_amount >= current_revive_cost:
		gold_amount -= current_revive_cost
		_update_gold_display()

		# Kademeli maliyet artışı (800 -> 2000 -> 3000 -> +1000)
		if current_revive_cost == 800:
			current_revive_cost = 2000
		elif current_revive_cost == 2000:
			current_revive_cost = 3000
		else:
			current_revive_cost += 1000

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
	current_revive_cost = 800 # 🏆 Yeni maç başladığında maliyet tekrar 800'e sıfırlanır!
	high_score_broken_this_game = false
	active_joker = JokerType.NONE
	_update_joker_buttons_visual()
	combo_timer.stop()
	score_label.text = t("score") % 0
	grid.reset_board()
	_new_tray()
	
	AdManager.show_game_over_ad()
	
	
