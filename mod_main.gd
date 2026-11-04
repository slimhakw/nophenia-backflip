extends Node


const SLIMHAKW_BACKFLIP_DIR := "slimhakw-Backflip"
const SLIMHAKW_BACKFLIP_LOG_NAME := "slimhakw-Backflip:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var BackflipAction = "backflip"
var Action = InputEventKey.new()

func _init() -> void:
    mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(SLIMHAKW_BACKFLIP_DIR)
    
    Action.physical_keycode = KEY_B
    InputMap.add_action(BackflipAction)
    InputMap.action_add_event("backflip",Action)
    
   




func _ready() -> void:
    ModLoaderLog.info("Ready!", SLIMHAKW_BACKFLIP_LOG_NAME)
    process_priority = 6767
    process_physics_priority = 6767



var nia
var rotating = false

var db_timer = 0

var camPosSave
var posSave
var offset = 0.66
var progress = 0.0
var timeToFlip = 0.62
var FlipTimer = 0
var flipDelay = 0.06



#var landSmok :CPUParticles3D

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("backflip"):
        
        nia = game.nia
        if not nia: return
        
        var unconscious = nia.unconscious
        var is_sitting = nia.is_sitting
        var is_paused = nia.is_paused
        if ( !unconscious and !is_sitting and !is_paused) and nia.is_on_floor() and not rotating:
            nia._jump_height = 1.8
            
           
                
                
            progress = 0.0
           
            camPosSave = nia.get_node("%cam_box").global_position.y
            posSave = nia.chara.position
            windupHappened = false
        
            nia.chara.scale = Vector3(1.3,0.7,1.3)#Vector3(0.7,1.3,0.7) # 
            sx = 0.7
            sy = 1.3
            speed = 3
            
    if rotating:
        nia = game.nia
        nia.get_node("%cam_box").global_position.y = camPosSave
      
        nia.chara.rotation.x = 2*PI*progress
        var basis = nia.chara.basis
        nia.chara.position = Vector3(0,offset,0)-basis*Vector3(0,offset,0.05)
       
var sx = 1
var sy = 1   
var speed = 1

var windupHappened =true
func _physics_process(delta: float) -> void:
    if nia:
        
       
        nia.chara.scale.x = move_toward(nia.chara.scale.x,sx,speed*delta)
        nia.chara.scale.y = move_toward(nia.chara.scale.y,sy,speed*delta)
        nia.chara.scale.z = move_toward(nia.chara.scale.z,sx,speed*delta)
        if nia.is_on_floor() and db_timer<=0 and rotating:
            
            nia = game.nia
            nia.chara.scale =Vector3(1.3,0.7,1.3)#Vector3(1.9,0.1,1.9) #
            rotating = false
            nia._jump_height = 0.8
            nia.chara.position = Vector3.ZERO
            
            nia.chara.rotation.x = 0
            
            
            nia.chara.rotation.x = 0
        if nia.chara.scale.y >= 1 and not windupHappened:
            windupHappened=true
        
            nia._is_jumping = true
            rotating = true
            FlipTimer = 0.0
            db_timer = 0.1
            speed = 3
        if nia.chara.scale.y >= 1.29  and windupHappened:
            speed = 1
            sx = 1
            sy = 1 
    
        
       
    
    if rotating and FlipTimer<=timeToFlip+flipDelay:
        FlipTimer+=delta
        progress=clamp((FlipTimer-flipDelay)/timeToFlip,0.0,1.0)
   
    db_timer-=delta
  
    
 
    
