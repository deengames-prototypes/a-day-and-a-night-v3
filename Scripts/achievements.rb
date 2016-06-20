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
    return "#{name.downcase.gsub(' ', '-').gsub('!', '').gsub("'", '')}.png"
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
  end

  def make_command_list
    super
    AchievementManager.achievements.each do |a|
      add_command(a.name, a.name.gsub(' ', '_').to_sym)
    end
  end

  def window_width
    return Graphics.width
  end

  def window_height
    return Graphics.height - 128 - 64
  end

  def get_achievement(index)
    AchievementManager.achievements[index]
  end

  # Run when the selected index changes
  def index=(index)
    super
    achievement = get_achievement(index)

    if !achievement.nil?
      @summary_window.refresh # clears the old text
      @summary_window.draw_text_ex(0, 0, "#{achievement.name}: " + (achievement.is_achieved ? achievement.description : '???'))

      @details_window.refresh # clears the old text
      @details_window.draw_text_ex(0, 0, achievement.is_achieved ? achievement.details : 'Locked.')
    end

    self.refresh
  end

  private

  def item_height
    ITEM_PADDING + IMAGE_HEIGHT
  end

  def item_width
    ITEM_PADDING + IMAGE_WIDTH
  end

  #--------------------------------------------------------------------------
  # * Number of columns
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end

  #--------------------------------------------------------------------------
  # * Get Spacing for Items Arranged Side by Side
  #--------------------------------------------------------------------------
  def spacing
    return 32
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    achievement = get_achievement(index)
    rectangle = item_rect(index)

    change_color(normal_color, command_enabled?(index))

    x = rectangle.x + ITEM_PADDING / 2
    y = rectangle.y + ITEM_PADDING / 2
	  image_name = achievement.is_achieved ? achievement.image : 'locked.png'
    image_name = "Graphics/Pictures/Achievements/#{image_name}"
	  contents.blt(x, y, Bitmap.new(image_name), Rect.new(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT), 255)
  end
end

class AchievementDetailsWindow < Window_Selectable
  def initialize
    super(0, Graphics.height - 128, Graphics.width, 128)
  end
end

### End region
