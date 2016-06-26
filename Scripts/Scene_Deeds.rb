#==============================================================================
# ** Scene_Deeds
#------------------------------------------------------------------------------
#  This class performs the deeds screen processing.
#==============================================================================
class Scene_Deeds < Scene_ItemBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    @selection_window = Window_DeedsSelection.new
    @selection_window.set_handler(:cancel, method(:return_scene))

    @selection_window.viewport = @viewport
  end
end

class Window_DeedsSelection < Window_Command

  def initialize()
    super(40, 100)
  end

  def make_command_list
    super
    #@@deeds = Array.new

    i = 0
    PointsSystem.get_points_scored.each do |key, value|
      #@@deeds.push(' (' + value.to_s + ')' + key.to_s)
      add_command(key, (value.to_s).to_sym)
    end
  end

  def get_deed(index)
    PointsSystem.get_points_scored[index]
    #@@deeds[index]
  end

  def window_width
    return Graphics.width - 80
  end

  def window_height
    return Graphics.height - 200
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    deed = get_deed(index)
    rectangle = item_rect(index)

    change_color(normal_color, command_enabled?(index))

    preset = ''
    postset = ''
    if deed.points > 0
      preset = '\C[3]+'
      postset = '\C[0]'
    elsif deed.points < 0
      preset = '\C[2]'
      postset = '\C[0]'
    end

    draw_text_ex(rectangle.x, rectangle.y, "#{preset}#{deed.points}#{postset} #{deed.event}")
  end

  def open
    refresh
    super
  end
end

#=============================
# Main menu summary window
#
#
# => Window_DeedsSummary is a LITTLE WINDOW IN THE MAIN MENU
# Shows x good, y bad deeds.
#
class Window_DeedsSummary < Window_Base
  def initialize
    super(0, 0, window_width, fitting_height(3))
    refresh
  end
  def window_width
    return 160
  end
  def window_height
    return 120
  end
  def total_good_deeds
    good_deeds = 0
    PointsSystem.get_points_scored.each do |p|
      if (p.points > 0)
        good_deeds = good_deeds + 1
      end
    end
    good_deeds
  end
  def total_bad_deeds
    bad_deeds = 0
    PointsSystem.get_points_scored.each do |p|
      if (p.points < 0)
        bad_deeds = bad_deeds + 1
      end
    end
    bad_deeds
  end
  def refresh
    contents.clear
    draw_text_ex(x, y, "Deeds\n#{value_good}\n#{value_bad}")
  end
  def value_bad
    bad = total_bad_deeds.to_s
    return "#{bad} Bad"
  end
  def value_good
    good = total_good_deeds.to_s
    return "#{good} Good"
  end
  def open
    refresh
    super
  end
end

#
# => Add summary window to main menu
#
class Scene_Menu
  alias d_start start
  alias d_update update
  def start
    d_start
    @deedsWindow = Window_DeedsSummary.new
    @deedsWindow.x = 0
    @deedsWindow.y = @gold_window.y - @deedsWindow.height - 56
    @deedsWindow.width = @gold_window.width
  end
end
