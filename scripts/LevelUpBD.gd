# LevelUpDB.gd
extends Node

# Mejoras por arma y nivel
var upgrades = {
	# ═══════════════════════════════════════
	# ARMAS ACTIVAS
	# ═══════════════════════════════════════
	
	"escopeta": {
		2: { "daño": 2 },
		3: { "perdigones": 1 },
		4: { "daño": 3 },
		5: { "perdigones": 1 },
		6: { "daño": 4 },
		7: { "perdigones": 1 },
		8: { "daño": 5 },
		9: { "perdigones": 1 },
		10: { "daño": 6, "perdigones": 1 },
	},
	
	"sniper": {
		2: { "daño": 5 },
		3: { "velocidad_proyectil": 100 },
		4: { "area_proyectil": 0.2 },
		5: { "daño": 7 },
		6: { "velocidad_proyectil": 150 },
		7: { "area_proyectil": 0.3 },
		8: { "daño": 10 },
		9: { "velocidad_proyectil": 200 },
		10: { "daño": 12, "area_proyectil": 0.5 },
	},
	
	"chakram": {
		2: { "daño": 3 },
		3: { "rebotes": 1 },
		4: { "velocidad_rebote": 50 },
		5: { "daño": 4 },
		6: { "rebotes": 1 },
		7: { "velocidad_rebote": 100 },
		8: { "daño": 6 },
		9: { "rebotes": 1 },
		10: { "daño": 8, "velocidad_rebote": 150 },
	},
	
	# ═══════════════════════════════════════
	# PASIVAS
	# ═══════════════════════════════════════
	
	"aura": {
		2: { "daño": 2 },
		3: { "tick": -0.05 },
		4: { "area": 15 },
		5: { "daño": 3 },
		6: { "tick": -0.05 },
		7: { "area": 20 },
		8: { "daño": 4 },
		9: { "tick": -0.1 },
		10: { "daño": 5, "area": 30 },
	},
	
	"sierras": {
		2: { "cantidad": 1 },
		3: { "daño": 2 },
		4: { "radio": 10 },
		5: { "velocidad_giro": 20 },
		6: { "cantidad": 1 },
		7: { "daño": 3 },
		8: { "radio": 15 },
		9: { "velocidad_giro": 30 },
		10: { "cantidad": 1, "daño": 4 },
	},
	
	"minas": {
		2: { "cantidad": 1 },
		3: { "area_explosion": 10 },
		4: { "cantidad": 1 },
		5: { "area_explosion": 15 },
		6: { "cantidad": 1 },
		7: { "area_explosion": 20 },
		8: { "cantidad": 2 },
		9: { "area_explosion": 25 },
		10: { "cantidad": 2, "area_explosion": 30 },
	},
	
	"dron": {
		2: { "velocidad_ataque": -0.05 },
		3: { "velocidad_proyectil": 50 },
		4: { "velocidad_ataque": -0.05 },
		5: { "velocidad_proyectil": 100 },
		6: { "velocidad_ataque": -0.1 },
		7: { "velocidad_proyectil": 150 },
		8: { "velocidad_ataque": -0.1 },
		9: { "velocidad_proyectil": 200 },
		10: { "velocidad_ataque": -0.15, "velocidad_proyectil": 250 },
	},
}

func get_upgrades(weapon_id: String, level: int) -> Dictionary:
	if not upgrades.has(weapon_id):
		push_warning("No hay upgrades para: ", weapon_id)
		return {}
	
	if not upgrades[weapon_id].has(level):
		return {}
	
	return upgrades[weapon_id][level]
