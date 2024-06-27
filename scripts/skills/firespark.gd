extends Skill
class_name Firespark

var damage := 90
var max_cooldown := 2

const firespark_scene = preload("res://scenes/firespark.tscn")
var caster: CombatCharacter
var target: CombatCharacter
var curr_firespark: FiresparkCombat
var curr_highlighted_cells: Array[Vector2i] = []

func use_skill(from: CombatCharacter, skill_pos: Vector2i, map: CombatMap) -> bool:
    var skill_target = map.get_character(skill_pos)
    if skill_target == null or not skill_target is AICombatCharacter:
        return false

    caster = from
    target = skill_target

    curr_firespark = firespark_scene.instantiate()
    from.get_parent().add_child(curr_firespark)
    curr_firespark.position = from.position
    curr_firespark.move_target = target.position
    curr_firespark.target_reached.connect(_on_reached_target)

    cooldown = max_cooldown
    return true
    
func get_skill_name() -> String:
    return "Firespark"

func get_skill_description() -> String:
    return "A basic fire attack that deals 90 damage to a ranged enemy."

func get_skill_icon() -> Texture:
    return load("res://assets/ui/skills/firespark.png")

func get_skill_range() -> int:
    return 4

func target_allies() -> bool:
    return false

func target_enemies() -> bool:
    return true

func target_self() -> bool:
    return false
    
func is_melee() -> bool:
    return false

func _on_reached_target(): 
    target.take_damage(damage)
    curr_firespark.queue_free()
    skill_finished.emit()

func highlight_targets(_from: CombatCharacter, _map: CombatMap) -> Array[Vector2i]:
    return []

func highlight_mouse_pos(from: CombatCharacter, mouse_pos: Vector2i, map: CombatMap) -> Array[Vector2i]:
    curr_highlighted_cells = HexHelper.fov(map.get_cell_coords(from.global_position), mouse_pos, map.can_walk) 
    for cell in curr_highlighted_cells: 
        if HexHelper.distance(map.get_cell_coords(from.global_position), cell) > get_skill_range():
            curr_highlighted_cells.erase(cell)
            continue
        var mouse_char = map.get_character(mouse_pos)
        if mouse_char != null and mouse_char is AICombatCharacter:
            map.set_cell(0, cell, 22, map.get_cell_atlas_coords(0, cell), 3)
        elif mouse_char == null :
            map.set_cell(0, cell, 22, map.get_cell_atlas_coords(0, cell), 4)
        

    return curr_highlighted_cells