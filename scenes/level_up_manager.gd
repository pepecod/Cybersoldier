extends Node

# Referencias
@onready var game_state = get_node("/root/GameState")
@onready var weapon_db = get_node("/root/WeaponDb")
@onready var hud_layer = get_node("../HUD")

# Escena del menu de seleccion
@export var passive_selection_scene: PackedScene = preload("res://scenes/PassiveSelection.tscn")

# Control de pasivas equipadas
const MAX_PASIVAS: int = 3

# Referencia al jugador
var player: CharacterBody2D

func _ready() -> void:
	await get_tree().process_frame
	
	if not hud_layer:
		push_error("No se encontró el nodo HUD")
	
	if game_state and game_state.has_signal("level_up"):
		game_state.level_up.connect(_on_level_up)
	
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _on_level_up(new_level: int) -> void:
	get_tree().paused = true
	
	var opciones = generar_opciones(new_level)
	
	if opciones.is_empty():
		get_tree().paused = false
		return
	
	mostrar_menu_seleccion(opciones)

func generar_opciones(nivel: int) -> Array:
	var pool: Array = []
	
	var armas_mejorables = obtener_armas_mejorables()
	pool.append_array(armas_mejorables)
	
	var pasivas_disponibles = obtener_pasivas_disponibles()
	pool.append_array(pasivas_disponibles)
	
	if pool.size() < 3:
		var todas_pasivas = weapon_db.get_passive_weapons()
		for pasiva in todas_pasivas:
			if pool.size() >= 3:
				break
			var ya_existe = false
			for item in pool:
				if item.id == pasiva.id:
					ya_existe = true
					break
			if not ya_existe:
				pool.append(pasiva)
	
	if pool.size() <= 3:
		return pool
	else:
		pool.shuffle()
		return pool.slice(0, 3)

func obtener_armas_mejorables() -> Array:
	var mejorables: Array = []
	
	if not player or not player.arma_actual:
		return mejorables
	
	var arma_id = game_state.selected_weapon_id
	
	if arma_id == "":
		return mejorables
	
	var weapon_data = weapon_db.get_weapon_by_id(arma_id)
	if weapon_data:
		mejorables.append(weapon_data)
	
	return mejorables

func obtener_pasivas_disponibles() -> Array:
	var disponibles: Array = []
	
	if player.pasivas_equipadas.size() > 0:
		for pasiva_node in player.pasivas_equipadas:
			for weapon in weapon_db.all_weapons:
				if weapon.type == "passive" and weapon.name in pasiva_node.name:
					disponibles.append(weapon)
					break
	
	if player.pasivas_equipadas.size() < MAX_PASIVAS:
		var pasivas_equipadas_nombres: Array = []
		for pasiva_node in player.pasivas_equipadas:
			pasivas_equipadas_nombres.append(pasiva_node.name)
		
		for weapon in weapon_db.all_weapons:
			if weapon.type == "passive":
				var ya_equipada = false
				for nombre in pasivas_equipadas_nombres:
					if weapon.name in nombre:
						ya_equipada = true
						break
				
				if not ya_equipada:
					disponibles.append(weapon)
	
	return disponibles

func mostrar_menu_seleccion(opciones: Array) -> void:
	if not hud_layer:
		return
	
	var menu = passive_selection_scene.instantiate()
	hud_layer.add_child(menu)
	
	menu.setup(opciones)
	menu.choice_made.connect(_on_choice_made)

func _on_choice_made(weapon_data) -> void:
	if weapon_data.type == "active":
		mejorar_arma_activa(weapon_data)
	elif weapon_data.type == "passive":
		if es_pasiva_equipada(weapon_data):
			mejorar_pasiva(weapon_data)
		else:
			equipar_nueva_pasiva(weapon_data)
	
	get_tree().paused = false

func mejorar_arma_activa(weapon_data) -> void:
	if not player or not player.arma_actual:
		return
	
	if player.arma_actual.has_method("level_up"):
		player.arma_actual.level_up()

func equipar_nueva_pasiva(weapon_data) -> void:
	if not player or not player.passive_holder:
		return
	
	if player.pasivas_equipadas.size() >= MAX_PASIVAS:
		return
	
	if not FileAccess.file_exists(weapon_data.scene_path):
		push_error("Archivo no existe: ", weapon_data.scene_path)
		return
	
	var pasiva_scene = load(weapon_data.scene_path) as PackedScene
	if not pasiva_scene:
		return
	
	var pasiva_instance = pasiva_scene.instantiate()
	if not pasiva_instance:
		return
	
	player.passive_holder.add_child(pasiva_instance)
	pasiva_instance.position = Vector2.ZERO
	player.pasivas_equipadas.append(pasiva_instance)

func mejorar_pasiva(weapon_data) -> void:
	if not player:
		return
	
	for pasiva_node in player.pasivas_equipadas:
		if weapon_data.name in pasiva_node.name:
			if pasiva_node.has_method("level_up"):
				pasiva_node.level_up()
			return

func es_pasiva_equipada(weapon_data) -> bool:
	if not player:
		return false
	
	for pasiva_node in player.pasivas_equipadas:
		if weapon_data.name in pasiva_node.name:
			return true
	
	return false
