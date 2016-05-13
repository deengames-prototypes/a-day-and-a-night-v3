# On the game over screen, show a window with points.
class Scene_Gameover < Scene_Base

  alias_method :old_start, :start
  
  def start
    old_start
    @points_summary_window = PointsSummaryWindow.new
    @points_summary_window.viewport = @viewport
    @points_summary_window.set_handler(:cancel, method(:return_scene))
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
    
    total_points = points.map { |p| p.points }.sum
    add_command("Total points: #{total_points}", :total_points)
    
    points.each do |p|
      add_command("#{p.event} (#{p.points} points)", p.event.gsub(' ', '-').to_sym)
      total_points += p.points
    end
    
  end
end