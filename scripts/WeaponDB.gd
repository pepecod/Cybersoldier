extends Node

class_name WeaponDB

class WeaponData:
	var name: String
	var scene_path: String
	var type: String
	var unlock_level: int
	var description: String
	var icon_path: String
	
	func _init(
		_name: String = "",
		_scene_path: String = "",
		_type: String = "active",
		_unlock_level: int = 1,
		_description: String = "",
		_icon_path: String = ""
	) -> void:
		name = _name
		scene_path = _scene_path
		type = _type
		unlock_level = _unlock_level
		description = _description
		icon_path = _icon_path

# Lista de todas las armas
var all_weapons: Array[WeaponData] = [
	WeaponData.new(
		"Chakram",
		"res://scenes/Armas/Holded/Chakram/proyectilchakram.tscn",
		"active",
		1,
		"Rebota entre varios enemigos antes de desaparecer.",
		"res://assets/armas/chakram.png"
	),
	WeaponData.new(
		"Sniper",
		"res://scenes/Armas/Holded/Sniper/sniper.tscn",
		"active",
		1,
		"Bala lenta y penetrante que atraviesa múltiples blancos.",
		"res://assets/armas/sniper.png"
	),
	WeaponData.new(
		"Escopeta",
		"res://scenes/Armas/Holded/Escopeta/escopeta.tscn",
		"active",
		1,
		"Dispara una nube de proyectiles cortos con gran dispersión.",
		"res://assets/armas/escopeta.png"
	),
	WeaponData.new(
		"Aura",
		"res://scenes/Armas/Pasivas/Aura/aura.tscn",
		"passive",
		1,
		"Genera un campo que daña a los enemigos cercanos.",
		"res://assets/armas/aura.png"
	),
	WeaponData.new(
		"Dron",
		"res://scenes/Armas/Pasivas/Dron/dron.tscn",
		"passive",
		1,
		"Un dron que dispara automáticamente a los enemigos.",
		"res://assets/armas/dron.png"
	),
	WeaponData.new(
		"Minas",
		"res://scenes/Armas/Pasivas/Minas/mina.tscn",
		"passive",
		1,
		"Coloca minas que explotan al paso de un enemigo.",
		"res://assets/armas/minas.png"
	),
	WeaponData.new(
		"Molotov",
		"res://scenes/Armas/Pasivas/Molotov/molotov.tscn",
		"passive",
		1,
		"Lanza cócteles molotov que prenden el suelo.",
		"res://assets/armas/molotov.png"
	),
	WeaponData.new(
		"Sierras",
		"res://scenes/Armas/Pasivas/Sierras/sierras.tscn",
		"passive",
		1,
		"Sierras giratorias que cortan todo a su paso.",
		"res://assets/armas/sierras.png"
	),
	WeaponData.new(
		"Lanzacohetes",
		"res://scenes/Armas/Definitivas/Lanzacohetes/lanzacohetes.tscn",
		"active",
		10,
		"Dispara cohetes balísticos de gran daño.",
		"res://assets/armas/lanzacohetes.png"
	),
	WeaponData.new(
		"Lanzallamas",
		"res://scenes/Armas/Definitivas/Lanzallamas/lanzallamas.tscn",
		"active",
		10,
		"Una ráfaga continua de fuego ígneo.",
		"res://assets/armas/lanzallamas.png"
	),
]

# Buscar arma por nombre
func get_weapon_by_name(weapon_name: String) -> WeaponData:
	for weapon in all_weapons:
		if weapon.name == weapon_name:
			return weapon
	return null

# Obtener armas por tipo
func get_weapons_by_type(weapon_type: String) -> Array[WeaponData]:
	var filtered: Array[WeaponData] = []
	for weapon in all_weapons:
		if weapon.type == weapon_type:
			filtered.append(weapon)
	return filtered

# Obtener pasivas
func get_passive_weapons() -> Array[WeaponData]:
	return get_weapons_by_type("passive")

# Obtener activas
func get_active_weapons() -> Array[WeaponData]:
	return get_weapons_by_type("active")
