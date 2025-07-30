extends Node2D
class_name ArmaBase

# Señales
signal disparado

# Variables exportadas
@export var daño: float = 10.0
@export var cadencia: float = 0.5  # segundos entre disparos
@export var sonido_disparo: AudioStream
@export var animacion_disparo: String = "disparo"

# Variables internas
var puede_disparar: bool = true

# Nodos
@onready var timer_cadencia: Timer = $Timer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready():
	timer_cadencia.wait_time = cadencia
	timer_cadencia.timeout.connect(_on_timer_cadencia_timeout)

func disparar(posicion: Vector2, direccion: Vector2) -> void:
	if not puede_disparar:
		return

	_logica_disparo(posicion, direccion)

	puede_disparar = false
	timer_cadencia.start()

	emit_signal("disparado")

	if sonido_disparo:
		audio_player.stream = sonido_disparo
		audio_player.play()

func _logica_disparo(posicion: Vector2, direccion: Vector2) -> void:
	# Método abstracto - implementar en clases hijas
	pass

func esta_disparando() -> bool:
	return not puede_disparar

func _on_timer_cadencia_timeout():
	puede_disparar = true
