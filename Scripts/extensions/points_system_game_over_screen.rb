# On the game over screen, show a window with points.
class Scene_Gameover < Scene_Base

  alias_method :old_start, :start
  
  def start
    old_start
    @points_summary_window = PointsSummaryWindow.new
    @points_summary_window.viewport = @viewport
    @points_summary_window.set_handler(:cancel, method(:go_to_title))
  end
  
  def go_to_title
    SceneManager.goto(Scene_Title)
  end
end

class PointsSummaryWindow < Window_Command
  def initialize
    super(0, 0)
  end
  
  def window_width
    return Graphics.width
  end
  
  def window_height
    return Graphics.height
  end
  
  def make_command_list    
    points = PointsSystem.get_points_scored    
    good_deeds = points.select { |p| p.points >= 0 }
    bad_deeds = points.select { |p| p.points < 0 }
    
    total_points = points.map { |p| p.points }.sum
    add_command("----- Total deeds: #{total_points} -----", :total_deeds)
    
    add_command("--- Good Deeds: #{good_deeds.length} ---", :good_deeds)    
    good_deeds.each do |p|
      add_command("#{p.event}", p.event.gsub(' ', '-').to_sym)      
    end
    
    add_command("--- Bad Deeds: #{bad_deeds.length} ---", :good_deeds)    
    bad_deeds.each do |p|
      add_command("#{p.event}", p.event.gsub(' ', '-').to_sym)      
    end
    
  end
end