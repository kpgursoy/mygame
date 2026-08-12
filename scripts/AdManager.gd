extends Node

# Google AdMob Test ID'leri (Kendi gerçek ID'lerini oyun çıkarken buraya yazacaksın)
var banner_id = "ca-app-pub-3940256099942544/6300978111"
var interstitial_id = "ca-app-pub-3940256099942544/1033173712"

var ad_view: AdView
var interstitial_ad: InterstitialAd
var interstitial_ad_load_callback := InterstitialAdLoadCallback.new()

func _ready():
	# SDK'yı başlat
	MobileAds.initialize()
	
	# Interstitial (Geçiş) reklamı yüklendiğinde yapılacaklar
	interstitial_ad_load_callback.on_ad_loaded = func(ad: InterstitialAd):
		interstitial_ad = ad
		interstitial_ad.show() # Yüklendiği an otomatik göster
		
	interstitial_ad_load_callback.on_ad_failed_to_load = func(error):
		print("Geçiş reklamı yüklenemedi: ", error.message)
	
	# Banner reklamı oluştur ve yükle (Ekranın alt kısmına sabitlenir)
	ad_view = AdView.new(banner_id, AdSize.BANNER, AdPosition.new(AdPosition.Values.BOTTOM))
	ad_view.load_ad(AdRequest.new())

# Oyun bittiğinde (Game Over) çağıracağın fonksiyon
func show_game_over_ad():
	# Tam ekran reklamı yükleme isteği gönder
	InterstitialAdLoader.new().load(interstitial_id, AdRequest.new(), interstitial_ad_load_callback)
