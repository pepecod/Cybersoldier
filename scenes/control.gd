# Menu.gd
extends Control

@onready var musica       : AudioStreamPlayer2D = $AudioMusica
@onready var video := $VideoPlayer
@onready var sfx_click    : AudioStreamPlayer2D = $SFXClick
@onready var main_menu    : VBoxContainer        = $CapaMenu/VBoxContainer
@onready var weapon_menu  : Control              = $CapaMenu/JugarMenu
@onready var decoracion   : TextureRect          = $FondoMain
@onready var decoracion2  : CanvasLayer          = $CapaMenu/JugarMenu/CapaMenu2

# Botones de selección de arma
@onready var btn_sel_escopeta : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/HBoxContainerEscopeta/Selescopeta
@onready var btn_sel_chakram  : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/HBoxContainerChakram/Selchakram
@onready var btn_sel_sniper   : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/HBoxContainerSniper/Selsniper

# Botones del MainMenu
@onready var btn_jugar      : Button = $CapaMenu/VBoxContainer/Jugar
@onready var btn_opciones   : Button = $CapaMenu/VBoxContainer/Opciones
@onready var btn_salir      : Button = $CapaMenu/VBoxContainer/Salir

# Botón "Volver" dentro de JugarMenu
@onready var btn_volver     : Button = $CapaMenu/JugarMenu/VBoxContainerMenu2/ScrollContainer/VBoxContainer/VolverMenu2

# Ruta de la escena de juego
const GAME_SCENE_PATH : String = "res://scenes/game.tscn"

@export var duracion_intro: float = 16.0

# Control de skip
var intro_terminada: bool = false
var nodos_listos: bool = false

# Label de skip
var label_skip: Label

func _ready() -> void:
	# Ocultar todo al arrancar
	decoracion.visible    = false
	main_menu.visible     = false
	weapon_menu.visible   = false
	decoracion2.visible   = false

	# Crear label de skip
	_crear_label_skip()

	# Arrancar música y vídeo
	musica.play()
	video.play()

	# Conectar señales de navegación
	btn_jugar.pressed.connect(_on_main_jugar_pressed)
	btn_opciones.pressed.connect(_on_main_opciones_pressed)
	btn_salir.pressed.connect(_on_main_salir_pressed)
	btn_volver.pressed.connect(_on_back_to_main)

	# Conectar selección de arma
	btn_sel_escopeta.pressed.connect(_on_sel_escopeta)
	btn_sel_chakram.pressed.connect(_on_sel_chakram)
	btn_sel_sniper.pressed.connect(_on_sel_sniper)
	
	# Conectar SFX
	for btn in [btn_jugar, btn_opciones, btn_salir, btn_volver, btn_sel_escopeta, btn_sel_chakram, btn_sel_sniper]:
		btn.pressed.connect(_play_click_sfx)
	
	# Marcar nodos como listos
	nodos_listos = true
	
	# Tras la intro, muestro el MainMenu
	await get_tree().create_timer(duracion_intro).timeout
	_terminar_intro()

func _crear_label_skip() -> void:
	label_skip = Label.new()
	label_skip.text = "Presiona ESPACIO para saltear"
	label_skip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Posicionar en la parte inferior
	label_skip.anchor_left = 0.0
	label_skip.anchor_top = 1.0
	label_skip.anchor_right = 1.0
	label_skip.anchor_bottom = 1.0
	label_skip.offset_top = -80
	label_skip.offset_bottom = -40
	
	# Estilo del texto
	label_skip.add_theme_font_size_override("font_size", 24)
	label_skip.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	label_skip.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label_skip.add_theme_constant_override("outline_size", 4)
	
	add_child(label_skip)
	
	# Efecto de parpadeo
	_animar_label_skip()

func _animar_label_skip() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(label_skip, "modulate:a", 0.3, 0.8)
	tween.tween_property(label_skip, "modulate:a", 1.0, 0.8)

func _input(event: InputEvent) -> void:
	# Skip intro con Espacio
	if event.is_action_pressed("ui_accept") and not intro_terminada and nodos_listos:
		_terminar_intro()

func _terminar_intro() -> void:
	if intro_terminada:
		return
	
	intro_terminada = true
	
	# Ocultar label de skip
	if label_skip:
		label_skip.visible = false
	
	_show_main_menu()

func _play_click_sfx() -> void:
	sfx_click.play()

func _show_main_menu() -> void:
	video.visible       = false
	decoracion.visible  = true
	main_menu.visible   = true
	weapon_menu.visible = false
	decoracion2.visible = false

func _on_main_jugar_pressed() -> void:
	main_menu.visible   = false
	weapon_menu.visible = true
	decoracion2.visible = true

func _on_main_opciones_pressed() -> void:
	pass

func _on_main_salir_pressed() -> void:
	get_tree().quit()

func _on_back_to_main() -> void:
	_show_main_menu()

# Handlers de selección
func _on_sel_escopeta() -> void:
	GameState.selected_weapon_index = 0
	GameState.selected_weapon_id = "escopeta" 
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_sel_chakram() -> void:
	GameState.selected_weapon_index = 1
	GameState.selected_weapon_id = "chakram" 
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_sel_sniper() -> void:
	GameState.selected_weapon_index = 2
	GameState.selected_weapon_id = "sniper"
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
