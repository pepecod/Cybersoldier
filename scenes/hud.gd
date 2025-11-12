# hud.gd
extends CanvasLayer

# Referencias a los elementos del HUD
@onready var hud_prota: TextureRect = $HudProta
@onready var barra_vida: TextureProgressBar = $BarraVida
@onready var hud_xp: TextureRect = $HudXP
@onready var barra_xp: TextureProgressBar = $BarraXP

# Variables de hovering
var tiempo: float = 0.0
var hover_amplitud: float = 5.0
var hover_velocidad: float = 2.0

# Posiciones originales
var pos_original_prota: Vector2
var pos_original_vida: Vector2
var pos_original_xp: Vector2
var pos_original_barra_xp: Vector2

func _ready() -> void:
	
	add_to_group("hud")
	# Guardar posiciones originales
	pos_original_prota = hud_prota.position
	pos_original_vida = barra_vida.position
	pos_original_xp = hud_xp.position
	pos_original_barra_xp = barra_xp.position
	
	_aplicar_glow()
	
	# Conectar al jugador
	await get_tree().process_frame
	var jugador = get_tree().get_first_node_in_group("player")
	if jugador:
		if jugador.has_signal("vida_cambiada"):
			jugador.vida_cambiada.connect(_on_vida_cambiada)
			actualizar_vida(jugador.vida_actual, jugador.vida_maxima)
	
	# Conectar al GameState
	if GameState:
		if GameState.has_signal("level_up"):
			GameState.level_up.connect(_on_level_up)
		actualizar_xp(GameState.xp, GameState.xp_to_next)

func _process(delta: float) -> void:
	tiempo += delta
	_actualizar_hovering()
	
	# Actualizar XP continuamente
	if GameState:
		actualizar_xp(GameState.xp, GameState.xp_to_next)

func _actualizar_hovering() -> void:
	var offset_y = sin(tiempo * hover_velocidad) * hover_amplitud
	
	hud_prota.position = pos_original_prota + Vector2(0, offset_y)
	barra_vida.position = pos_original_vida + Vector2(0, offset_y)
	
	var offset_y_xp = sin(tiempo * hover_velocidad + 1.0) * hover_amplitud
	hud_xp.position = pos_original_xp + Vector2(0, offset_y_xp)
	barra_xp.position = pos_original_barra_xp + Vector2(0, offset_y_xp)

func _aplicar_glow() -> void:
	# Por ahora vacío, lo implementamos después
	pass

func shake_vida() -> void:
	_shake_element(hud_prota, pos_original_prota)
	_shake_element(barra_vida, pos_original_vida)

func shake_xp() -> void:
	_shake_element(hud_xp, pos_original_xp)
	_shake_element(barra_xp, pos_original_barra_xp)

func _shake_element(elemento: Control, pos_original: Vector2) -> void:
	var tween = create_tween()
	var intensidad = 10.0
	
	for i in range(4):
		var offset_random = Vector2(randf_range(-intensidad, intensidad), randf_range(-intensidad, intensidad))
		tween.tween_property(elemento, "position", pos_original + offset_random, 0.05)
	
	tween.tween_property(elemento, "position", pos_original, 0.1)

func actualizar_vida(vida_actual: float, vida_maxima: float) -> void:
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual

func actualizar_xp(xp_actual: int, xp_necesario: int) -> void:
	barra_xp.max_value = xp_necesario
	barra_xp.value = xp_actual

func _on_vida_cambiada(vida_actual: float, vida_maxima: float) -> void:
	actualizar_vida(vida_actual, vida_maxima)
	shake_vida()

func _on_level_up(new_level: int) -> void:
	shake_xp()
	actualizar_xp(GameState.xp, GameState.xp_to_next)
