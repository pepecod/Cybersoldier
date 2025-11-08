extends ArmaBase
class_name Escopeta

# Configuración
@export var perdigon_scene: PackedScene = preload("res://scenes/Armas/Holded/Escopeta/perdigones.tscn")
@export var angulo_cono: float = 0.5  # En radianes (0.5 ≈ 28°)
@export var velocidad_proyectil: float = 800.0
@export var cadencia_disparo: float = 0.8  # Segundos entre disparos
@onready var level_up_bd = get_node("/root/LevelUpBD")

# Nodos
@onready var audio_disparo: AudioStreamPlayer2D = $AudioDisparo
@onready var efecto_disparo: GPUParticles2D = $EfectoDisparo
@onready var spawn_node: Marker2D = $BulletSpawn


# Variables
var nivel: int = 0
var perdigones_adicionales: int = 0


func _ready():
	if not perdigon_scene:
		push_error("ERROR: No se cargó la escena del perdigón")
		queue_free()
	timer_cadencia.wait_time = cadencia_disparo
	timer_cadencia.timeout.connect(_on_cadencia_timeout)

func set_spawn_node(nodo: Marker2D) -> void:
	spawn_node = nodo

func _logica_disparo(posicion: Vector2, direccion_base: Vector2) -> void:
	var spawn_pos = spawn_node.global_position if spawn_node != null else posicion
	print("Usando spawn_pos:", spawn_pos)
	var angulo_base = direccion_base.angle()

	var perdigones_a_disparar = calcular_numero_perdigones()
	for i in range(perdigones_a_disparar):
		var factor = (float(i) / max(1.0, perdigones_a_disparar - 1)) * 2.0 - 1.0
		var angulo = angulo_base + (factor * angulo_cono / 2.0)
		var dir_perdigon = Vector2.RIGHT.rotated(angulo)

		var perdigon = perdigon_scene.instantiate()
		get_tree().current_scene.add_child(perdigon)
		perdigon.global_position = spawn_pos
		perdigon.direccion = dir_perdigon
		perdigon.velocidad = velocidad_proyectil
		perdigon.daño = calcular_dano_perdigon()
		perdigon.creador = self

func calcular_dano_perdigon() -> float:
	return daño / calcular_numero_perdigones()

func calcular_numero_perdigones() -> int:
	return 4 + perdigones_adicionales

func _on_cadencia_timeout():
	puede_disparar = true

func esta_disparando() -> bool:
	return not puede_disparar
func level_up() -> void:
	nivel += 1
	
	var upgrades = level_up_bd.get_upgrades("escopeta", nivel)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
		print("✅ Escopeta nivel ", nivel, " | Daño +", upgrades["daño"])
	
	if upgrades.has("perdigones"):
		perdigones_adicionales += upgrades["perdigones"]
		print("✅ Escopeta nivel ", nivel, " | Perdigones +", upgrades["perdigones"])
