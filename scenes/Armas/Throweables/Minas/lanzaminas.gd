extends Node2D

@export var mina_scene: PackedScene
@export var cantidad_por_oleada: int = 2
@export var radio_spawn: float = 100.0
@export var intervalo_spawn: float = 5.0

@onready var level_up_bd = get_node("/root/LevelUpBD")

var jugador: CharacterBody2D
var timer: Timer

# Variables de mejora
var nivel_actual: int = 1
var cantidad_adicional: int = 0
var area_explosion_adicional: float = 0.0

func _ready() -> void:
	jugador = get_parent().get_parent()
	
	if not mina_scene:
		push_error("mina_scene no está asignada")
		return
	
	timer = Timer.new()
	timer.wait_time = intervalo_spawn
	timer.timeout.connect(spawnear_grupo)
	add_child(timer)
	timer.start()
	
	spawnear_grupo()

func spawnear_grupo() -> void:
	var cantidad_total = cantidad_por_oleada + cantidad_adicional
	for i in cantidad_total:
		spawnear_mina()

func spawnear_mina() -> void:
	if not mina_scene:
		return
	
	var mina = mina_scene.instantiate()
	
	var angulo = randf() * TAU
	var distancia = radio_spawn
	var offset = Vector2(cos(angulo), sin(angulo)) * distancia
	
	get_tree().current_scene.add_child(mina)
	mina.global_position = jugador.global_position + offset
	
	# Aplicar mejoras a la mina
	mina.radio_explosion = 80.0 + area_explosion_adicional

func level_up() -> void:
	nivel_actual += 1
	
	var upgrades = level_up_bd.get_upgrades("minas", nivel_actual)
	aplicar_mejoras(upgrades)

func aplicar_mejoras(upgrades: Dictionary) -> void:
	if upgrades.has("cantidad"):
		cantidad_adicional += upgrades["cantidad"]
		print("Minas nivel ", nivel_actual, " | Cantidad +", upgrades["cantidad"])
	
	if upgrades.has("area_explosion"):
		area_explosion_adicional += upgrades["area_explosion"]
		print("Minas nivel ", nivel_actual, " | Area explosion +", upgrades["area_explosion"])
