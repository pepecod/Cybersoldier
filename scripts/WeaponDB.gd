extends Node
class_name WeaponDB

class WeaponData:
	var id: String
	var name: String
	var scene_path: String
	var type: String
	var unlock_level: int
	var description: String
	var icon_path: String
	
	func _init(
		_id: String = "",
		_name: String = "",
		_scene_path: String = "",
		_type: String = "active",
		_unlock_level: int = 1,
		_description: String = "",
		_icon_path: String = ""
	) -> void:
		id = _id
		name = _name
		scene_path = _scene_path
		type = _type
		unlock_level = _unlock_level
		description = _description
		icon_path = _icon_path

# Lista de todas las armas
var all_weapons: Array[WeaponData] = [
	WeaponData.new(
		"chakram",
		"Chakram",
		"res://scenes/Armas/Holded/Chakram/proyectilchakram.tscn",
		"active",
		1,
		"Rebota entre varios enemigos antes de desaparecer.",
		"res://assets/armas/iconos/chakram_icon.png"
	),
	WeaponData.new(
		"sniper",
		"Sniper",
		"res://scenes/Armas/Holded/Sniper/sniper.tscn",
		"active",
		1,
		"Bala lenta y penetrante que atraviesa múltiples blancos.",
		"res://assets/armas/iconos/sniper_icon.png"
	),
	WeaponData.new(
		"escopeta",
		"Escopeta",
		"res://scenes/Armas/Holded/Escopeta/escopeta.tscn",
		"active",
		1,
		"Dispara una nube de proyectiles cortos con gran dispersión.",
		"res://assets/armas/iconos/escopeta_icon.png"
	),
	WeaponData.new(
		"aura",
		"Aura",
		"res://scenes/Armas/Throweables/Aura/aura.tscn",
		"passive",
		1,
		"Genera un campo que daña a los enemigos cercanos.",
		"res://assets/armas/iconos/aura_icon.png"
	),
	WeaponData.new(
		"dron",
		"Dron",
		"res://scenes/Armas/Throweables/Dron/dron.tscn",
		"passive",
		1,
		"Un dron que dispara automáticamente a los enemigos.",
		"res://assets/armas/iconos/dron_icon.png"
	),
	WeaponData.new(
		"minas",
		"Minas",
		"res://scenes/Armas/Throweables/Minas/lanzaminas.tscn",
		"passive",
		1,
		"Coloca minas que explotan al paso de un enemigo.",
		"res://assets/armas/iconos/minas_icon.png"
	),
	WeaponData.new(
		"sierras",
		"Sierras",
		"res://scenes/Armas/Throweables/Sierras/sistema_sierras.tscn",
		"passive",
		1,
		"Sierras giratorias que cortan todo a su paso.",
		"res://assets/armas/iconos/sierra_icon.png"
	),
	WeaponData.new(
		"lanzacohetes",
		"Lanzacohetes",
		"res://scenes/Armas/Definitivas/Lanzacohetes/lanzacohetes.tscn",
		"active",
		10,
		"Dispara cohetes balísticos de gran daño.",
		"res://assets/armas/lanzacohetes.png"
	),
	WeaponData.new(
		"lanzallamas",
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

# Buscar arma por ID
func get_weapon_by_id(weapon_id: String) -> WeaponData:
	for weapon in all_weapons:
		if weapon.id == weapon_id:
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
