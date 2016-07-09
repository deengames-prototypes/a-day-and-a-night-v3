###
# Trigger Bar: adds a "trigger" bar and you press to attack at the right time
# Doing so causes certain effects (1.5x damage on attack, 0.5x damage on defend,
# apply status effect on attack, nullify status effect on defend).
# 
# Version: 1.0
# Author: ashes999 (ashes999@yahoo.com)
###

class Scene_Battle < Scene_Base
  
  alias :trigger_turn_start :turn_start  
  def turn_start
    trigger_turn_start    
  end
  
  alias :trigger_turn_end :turn_end
  def turn_end
    trigger_turn_end
  end
  
  alias :trigger_post_start :post_start
  def post_start
    trigger_post_start
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
  end
  
  alias :trigger_terminate :terminate
  def terminate
    dispose_image(@bar)
    dispose_image(@hit_area)
    dispose_image(@trigger)
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
end
