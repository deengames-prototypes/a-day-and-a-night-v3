###
# Achievements live across all games. They're also associated with fancy images and such.
# TODO: this is still very, very rough.
### 

# Everything's static. It's easier that way.
class AchievementManager
  ACHIEVEMENTS_FILE = 'achievements.dat'
  @@achievements = []
  
  def self.initialize(default_achievements)
    if File.exist?(ACHIEVEMENTS_FILE)
      @@achievements = Serializer.deserialize(ACHIEVEMENTS_FILE)
      
      # Add any new default achievements that are not in the file or update fields
      default_achievements.each do |d|
        list = @@achievements.select { |a| a.name == d.name }
        if list.length == 0
          @@achievements << d
        else
          # update everything but the name
          a = list.first
          a.description = d.description
          a.details = d.details
        end
      end
    else
      @@achievements = default_achievements
    end
    
    Logger.log "Achievements are #{@@achievements}"
  end
  
  def self.save
    Serializer.serialize(AchievementManager.achievements, ACHIEVEMENTS_FILE)        
  end
  
  def self.achievements
    return @@achievements
  end
end

# An achievement
class Achievement

  attr_accessor :name, :description, :details
  attr_reader :is_achieved
  
  def initialize(name, description, details)
    @name = name
    @description = description
    @details = details
    @is_achieved = false
  end
    
  def achieve
    return if @is_achieved == true
    @is_achieved = true
    AchievementManager.save
    play_sound
    show_popup
  end
  
  def play_sound
    Audio.se_play("Audio/SE/Shop", 80, 100)
  end
  
  def show_popup    
    $game_map.interpreter.event_window_add_text("Achievement unlocked: #{self.name}")
    $game_map.interpreter.event_window_clear_text
  end
  
  def image
    return "Graphics/Pictures/Achievements/#{name.downcase.gsub(' ', '-')}.png"
  end
end

# A list of events, and what "time" they occurred (in ticks). Use these to decide
# what achievements to grant the user. 
class EventRecorder
  attr_accessor :events
  
  def note_event(name)
    # time = now_in_ticks
    @events << Event.new(name)
  end
  
  def has?(name)
    to_return = []
    @events.each do |e|
      to_return << e if e.name.downcase == name.downcase
    end
    return to_return
  end
end

# An event. Has a name and a time. (Time is in ticks so that if you save, quit, and reload
# the next day, you can still achieve achievements that need to be done relatively quickly).
class Event
  attr_accessor :name, :achieved_on_ticks
  
  def new(name, time)
    @name = name
    @achieved_on_ticks = time
  end
end

### Region: UI


class AchievementsScene < Scene_Base
  # Three windows:
  # 1) Thin top window (achievement name and description))
  # 2) Thin bottom window (achievement details)
  # 3) Middle window (images, keyboard to select)
  def start
    super
    @summary_window = AchievementSummaryWindow.new
    @details_window = AchievementDetailsWindow.new
    @selection_window = AchievementsSelectionWindow.new(@summary_window, @details_window)
    @selection_window.set_handler(:cancel, method(:return_scene))
    
    @summary_window.viewport = @viewport
    @details_window.viewport = @viewport
    @selection_window.viewport = @viewport
  end
end

class AchievementSummaryWindow < Window_Selectable
  def initialize
    super(0, 0, Graphics.width, 64)
  end
end

class AchievementsSelectionWindow < Window_Command

  IMAGE_WIDTH = 100
  IMAGE_HEIGHT = 100
  ITEM_PADDING = 16

  def initialize(summary_window, details_window)
    @summary_window = summary_window
    @details_window = details_window
    super(0, 64)
    redraw_all_achievements
  end
  
  def make_command_list
    super
    AchievementManager.achievements.each do |a|
      add_command(a.name, a.name.gsub(' ', '_').to_sym) if a.is_achieved   
    end
  end
  
  def window_width
    return Graphics.width
  end
  
  def window_height
    return Graphics.height - 128 - 64
  end
  
  # Run when the selected index changes
  def index=(index)  
    super
    achievement = AchievementManager.achievements.select{ |a| a.is_achieved }[index]
    
    if !achievement.nil?    
      @summary_window.refresh # clears the old text    
      @summary_window.draw_text_ex(0, 0, "#{achievement.name}: #{achievement.description}")

      @details_window.refresh # clears the old text      
      @details_window.draw_text_ex(0, 0, achievement.details)    
    end
    
    self.refresh    
  end
  
  private
  
  def redraw_all_achievements
    i = 0
    AchievementManager.achievements.select{ |a| a.is_achieved }.each do |achievement|      
      # Strange formula: treat each item as (item + padding) wide. 
      # We only need to subtract extra padding for the first item, since it's located at x=ITEM_PADDING
      # (The last item's padding will hit the end of the window, so we're covered.)
      items_per_row = (self.window_width - ITEM_PADDING) / (IMAGE_WIDTH + ITEM_PADDING)
      row = i / items_per_row
      column = i % items_per_row
      x = ITEM_PADDING + (column * (IMAGE_WIDTH + ITEM_PADDING))
      y = ITEM_PADDING + (row * (IMAGE_HEIGHT + ITEM_PADDING))
      Logger.log("Drawing #{achievement.name} at #{x}, #{y}")
      contents.blt(x, y, Bitmap.new(achievement.image), Rect.new(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT), 255)      
      i += 1
    end
  end
end

class AchievementDetailsWindow < Window_Selectable
  def initialize
    super(0, Graphics.height - 128, Graphics.width, 128)
  end
end

### End region
