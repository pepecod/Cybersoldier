# MusicPlayer.gd
extends Node

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var audio_effect_bus: AudioEffectLowPassFilter

var playlist: Array[AudioStream] = []
var current_track_index: int = 0
var shuffle: bool = false
var volumen_normal: float = 0.0  # dB
var volumen_level_up: float = -15.0  # dB (más bajo)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	music_player.bus = "Music"  # Usaremos un bus separado para efectos
	music_player.finished.connect(_on_track_finished)
	
	# Cargar todas las canciones de la carpeta OST
	cargar_playlist("res://assets/sounds/OST/")
	
	# Configurar audio bus con filtro
	_configurar_audio_bus()
	
	# Iniciar reproduccióm
func iniciar_musica() -> void:
	if playlist.size() > 0:
		play_track(0)

func cargar_playlist(ruta: String) -> void:
	var dir = DirAccess.open(ruta)
	if not dir:
		push_error("No se pudo abrir la carpeta: ", ruta)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			# Solo archivos de audio (.ogg, .mp3, .wav)
			if file_name.ends_with(".ogg") or file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
				var stream = load(ruta + file_name)
				if stream:
					playlist.append(stream)
					print("Canción añadida: ", file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	if shuffle:
		playlist.shuffle()
	
	print("Playlist cargada: ", playlist.size(), " canciones")

func _configurar_audio_bus() -> void:
	# Crear bus "Music" si no existe
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index == -1:
		AudioServer.add_bus()
		bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(bus_index, "Music")
	
	# Añadir efecto LowPass
	var lowpass = AudioEffectLowPassFilter.new()
	lowpass.cutoff_hz = 20000  # Normal (sin filtro)
	AudioServer.add_bus_effect(bus_index, lowpass)
	audio_effect_bus = AudioServer.get_bus_effect(bus_index, 0)

func play_track(index: int) -> void:
	if index < 0 or index >= playlist.size():
		return
	
	current_track_index = index
	music_player.stream = playlist[index]
	music_player.play()
	print("Reproduciendo: ", playlist[index].resource_path)

func _on_track_finished() -> void:
	# Pasar a la siguiente canción
	current_track_index = (current_track_index + 1) % playlist.size()
	play_track(current_track_index)

func aplicar_efecto_level_up() -> void:
	# Bajar volumen
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", volumen_level_up, 0.3)
	
	# Aplicar filtro "pecera" (lowpass)
	audio_effect_bus.cutoff_hz = 500  # Frecuencia baja = sonido apagado

func quitar_efecto_level_up() -> void:
	# Restaurar volumen
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", volumen_normal, 0.5)
	
	# Quitar filtro
	audio_effect_bus.cutoff_hz = 20000  # Frecuencia completa

func pausar() -> void:
	music_player.stream_paused = true

func reanudar() -> void:
	music_player.stream_paused = false

func detener() -> void:
	music_player.stop()

func set_volume(db: float) -> void:
	volumen_normal = db
	music_player.volume_db = db
