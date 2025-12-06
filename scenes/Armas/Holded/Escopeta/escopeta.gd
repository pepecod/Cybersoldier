extends ArmaBase
class_name Escopeta

# Configuración
@export var angulo_cono: float = 0.5  # En radianes (0.5 ≈ 28°)
@export var velocidad_proyectil: float = 800.0
@export var cadencia_disparo: float = 0.8

@onready var level_up_bd = get_node("/root/LevelUpBD")

# Nodos
@onready var audio_disparo: AudioStreamPlayer2D = $AudioDisparo
@onready var efecto_disparo: GPUParticles2D = $EfectoDisparo
@onready var spawn: Marker2D = $BulletSpawn

# Variables
var nivel: int = 0
var perdigones_adicionales: int = 0

func _ready():
	timer_cadencia.wait_time = cadencia_disparo
	timer_cadencia.timeout.connect(_on_cadencia_timeout)

func _logica_disparo(pos: Vector2, dir: Vector2) -> void:
	var num_perdigones = calcular_numero_perdigones()
	var daño_total = daño + daño_adicional
	
	for i in num_perdigones:
		#Aleatorizar el angulo para que parezca mas una escopeta, y no estar tan op
		var angulo_offset = randf_range(-angulo_cono, angulo_cono)
		var direccion_perdigon = dir.rotated(angulo_offset)
		
		ProjectileFactory.crear_perdigon(
			spawn.global_position,
			direccion_perdigon,
			daño_total,
			self
		)

func calcular_numero_perdigones() -> int:
	return 4 + perdigones_adicionales

func _on_cadencia_timeout():
	puede_disparar = true

func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("escopeta", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("Escopeta nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("perdigones"):
		perdigones_adicionales += upgrades["perdigones"]
		print("Escopeta nivel ", nivel, " | Perdigones +", upgrades["perdigones"])
