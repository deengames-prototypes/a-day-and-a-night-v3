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
    # position of selectionWindow
    x = 40
    y = 100
    width = Graphics.width - 80
    height = Graphics.height - 200

    @selection_window = Window_DeedsSelection.new(x, y, width, height)
    @selection_window.set_handler(:cancel, method(:return_scene))
    @selection_window.viewport = @viewport

    @title_window = Window_Text.new(x, y - fitting_height(1), width, fitting_height(1), "Muhasaba (Self-Accountability)")
    @title_window.viewport = @viewport

    @total_window = Window_DeedsTotal.new(x, y + height, width, fitting_height(1))
    @total_window.viewport = @viewport
  end

  #--------------------------------------------------------------------------
  # * Borrowed from Window_Base
  #--------------------------------------------------------------------------
  def fitting_height(line_number)
    line_number * line_height + standard_padding * 2
  end
  def line_height
    return 24
  end
  def standard_padding
    return 12
  end
  #--------------------------------------------------------------------------
  # * No More borrowing from Window_Base
  #--------------------------------------------------------------------------
end
class Window_DeedsTotal < Window_Base
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @@width = width
    refresh
  end
  def refresh
    contents.clear

    points = PointsSystem.total_points

    preset = ''
    postset = '\C[0]'
    if points >= 0
      preset = '\C[4]+'
    elsif points < 0
      preset = '\C[2]'
    end

    draw_text_ex(0, 0, "Total")
    total = "#{preset}#{points}#{postset}"

    endOfWindowX = x + @@width - text_size(total).width + 24 # add 24 because preset/postset add "ghost" width
    draw_text_ex(endOfWindowX, 0, total)
  end
  def open
    super
    refresh
  end
end

class Window_Text < Window_Base
  def initialize(x, y, width, height, value)
    super(x, y, width, height)
    @@width = width
    @@height = height
    @@value = value
    refresh
  end
  def window_width
    @@width
  end
  def window_height
    @@height
  end
  def refresh
    contents.clear
    draw_text_ex(0, 0, @@value)
  end
end

class Window_DeedsSelection < Window_Command

  def initialize(x, y, width, height)
    @@width = width
    @@height = height
    super(x, y)
  end

  def window_width
    @@width
  end

  def window_height
    @@height
  end

  def make_command_list
    super
    #@@deeds = Array.new

    i = 0
    PointsSystem.get_points_scored.each do |key, value|
      add_command(key, (value.to_s).to_sym)
    end
  end

  def get_deed(index)
    PointsSystem.get_points_scored[index]
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    deed = get_deed(index)
    rectangle = item_rect(index)

    change_color(normal_color, command_enabled?(index))

    preset = ''
    postset = '\C[0]'
    if deed.points >= 0
      preset = '\C[4]'
    elsif deed.points < 0
      preset = '\C[2]'
    end

    draw_text_ex(rectangle.x, rectangle.y, "#{preset}#{deed.event}#{postset}")

    endOfWindowX = x + @@width + 24 # add 24 because preset/postset add "ghost" width
    draw_text_ex(endOfWindowX, rectangle.y, 0)
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
    super(0, 0, window_width, fitting_height(4) + 16)
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
    draw_text_ex(x, y, "Deeds:\n#{value_good}\n#{value_bad}")
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
