extends Node2D

@export var sierra_scene: PackedScene
@export var nivel_inicial: int = 1

@onready var level_up_bd = get_node("/root/LevelUpBD")

var nivel_actual: int = 1
var sierras: Array = []

# Variables de mejora
var cantidad_adicional: int = 0
var daño_adicional: float = 0.0
var radio_adicional: float = 0.0
var velocidad_giro_adicional: float = 0.0

func _ready() -> void:
	if not sierra_scene:
		push_error("sierra_scene no está asignada")
		return
	
	nivel_actual = nivel_inicial
	crear_sierras()

func crear_sierras() -> void:
	destruir_sierras()
	
	var cantidad_base = 2
	var cantidad_total = cantidad_base + cantidad_adicional
	
	for i in cantidad_total:
		var sierra = sierra_scene.instantiate()
		add_child(sierra)
		
		# Ángulo inicial distribuido uniformemente
		var angulo_inicial = (TAU / cantidad_total) * i
		sierra.angulo = angulo_inicial
		
		# Aplicar mejoras
		sierra.damage = 20.0 + daño_adicional
		sierra.radio_orbita = 100.0 + radio_adicional
		sierra.velocidad_giro = 2.0 + velocidad_giro_adicional
		
		sierras.append(sierra)

func destruir_sierras() -> void:
	for sierra in sierras:
		if is_instance_valid(sierra):
			sierra.queue_free()
	sierras.clear()

func level_up() -> void:
	nivel_actual += 1
	
	var upgrades = level_up_bd.get_upgrades("sierras", nivel_actual)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("cantidad"):
		cantidad_adicional += upgrades["cantidad"]
		
	
	if upgrades.has("daño"):
		daño_adicional += upgrades["daño"]
	
	if upgrades.has("radio"):
		radio_adicional += upgrades["radio"]
	
	if upgrades.has("velocidad_giro"):
		velocidad_giro_adicional += upgrades["velocidad_giro"]
	
	# Recrear sierras con las mejoras aplicadas
	crear_sierras()

func _exit_tree() -> void:
	destruir_sierras()
