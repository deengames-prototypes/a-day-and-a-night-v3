###
# Trigger Bar: adds a "trigger" bar and you press to attack at the right time
# Doing so causes certain effects (1.5x damage on attack, 0.5x damage on defend,
# apply status effect on attack, nullify status effect on defend).
#
# Requires Yanfly's Keyboard Input script.
# Only works with Yanfly's battle engine.
# 
# Version: 1.0
# Author: ashes999 (ashes999@yahoo.com)
###

class Scene_Battle < Scene_Base
  
  # How long the bar is on-screen.
  TRIGGER_TIME_IN_SECONDS = 0.65
  
  ####### Do not change codez below unless you know what you are doing! #######
  
  NORMAL_ATTACK_DATA_ID = 0
  
  alias :trigger_start :start
  def start
    trigger_start
    @bar = create_image('trigger_bar')
    @bar.x = (Graphics.width - @bar.width) / 2
    @bar.y = 100
    
    @hit_area = create_image('trigger_bar_hit_area')
    @hit_area.x = @bar.x + (@bar.width - @hit_area.width) * 2 / 3 # two-thirds of the way to the right
    @hit_area.y = @bar.y - (@hit_area.height - @bar.height) / 2
    @hit_area.z = @bar.z + 1
    
    @trigger = create_image('trigger_bar_trigger')
    @trigger.x = @bar.x
    @trigger.y = @bar.y - @trigger.height
    
    hide_bar
    
    @trigger_velocity = @bar.width / (60 * TRIGGER_TIME_IN_SECONDS)
  end  
  
  alias :trigger_execute_action :execute_action  
  def execute_action    
    attacker = @subject
    action = attacker.current_action
    @trigger.x = @bar.x    
    if !action.nil? && action.attack?    
      show_bar
      @trigger_moving = true
      @trigger_start = Time.now
    end
    trigger_execute_action
  end
  
  alias :trigger_update_basic :update_basic
  def update_basic    
    if @trigger_moving == true
      @trigger.x += @trigger_velocity
      if Input.key_pressed?(:SPACE) || Input.key_pressed?(:ENTER)
        # Visual feedback: hit or miss
        is_hit = @trigger.x >= @hit_area.x && @trigger.x + @trigger.width <= @hit_area.x + @hit_area.width
        
        if is_hit
          attacker = @subject
          action = attacker.current_action          
          effects = action.item.effects          
          @original_damage = {:attacker => attacker, :item => action.item, :damage => action.item.damage, :formula => action.item.damage.formula, :effects => effects}
          Logger.log("atk=#{attacker} and action=#{action}")
          
          if ($game_party.members.include?(attacker))
            # Player attacking: 1.5x damage
            Logger.log("Player attacking: 1.5x #{action.item.damage.formula}")
            action.item.damage.formula = "1.5 * (#{action.item.damage.formula})"
            # Force any status effects
            effects.each do |e|
              e.value1 = 1 # 100% probability
            end              
          else
            # Monster attacking: 0.5x damage
            Logger.log("Monster attacking: 0.5x #{action.item.damage.formula}")
            action.item.damage.formula = "0.5 * (#{action.item.damage.formula})"
            # Nullify any status effects
            effects.each do |e|
              e.value1 = 0 unless e.data_id = NORMAL_ATTACK_DATA_ID # 0% probability except for "Normal Attack"
            end
          end
        else
          @original_damage = nil
        end
        
        # No more moving, kthxbye
        @trigger_moving = false
        hide_bar
      end
    end
        
    @trigger.opacity = 0 if @trigger.x >= @bar.x + @bar.width
    # Don't progress battle (fight animations) if the bar is visible
    if @trigger_moving == true && (Time.now - @trigger_start) <= TRIGGER_TIME_IN_SECONDS
      # Selective codez from Scene_Battle.update
      Graphics.update
      Input.update
    else
      trigger_update_basic 
    end
  end
  
  alias :trigger_process_action_end :process_action_end
  def process_action_end
    @trigger_moving = false
    hide_bar
    trigger_process_action_end   
    # Reset damage on this action
    reset_damage
  end
  
  alias :trigger_terminate :terminate
  def terminate
    reset_damage
    dispose_image(@bar)
    dispose_image(@hit_area)
    dispose_image(@trigger)    
    trigger_terminate
  end
  
  private
  
  def create_image(filename)
    image = Sprite.new
    image.bitmap = Cache.picture(filename)
    return image
  end
  
  def dispose_image(image)
    image.bitmap.dispose
    image.dispose
  end
  
  def show_bar
    @bar.opacity = 255
    @hit_area.opacity = 255
    @trigger.opacity = 255
  end
  
  def hide_bar
    @bar.opacity = 0
    @hit_area.opacity = 0
    @trigger.opacity = 0
  end
  
  def reset_damage
    if !@original_damage.nil?
      @original_damage[:damage].formula = @original_damage[:formula]
      @original_damage[:item].effects = @original_damage[:effects]            
    end
  end
end
