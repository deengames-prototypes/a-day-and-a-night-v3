# For use with Advanced Game Time; the save game screen shows the current time
# instead of the total gameplay time. Only shows hours and minutes, because
# my game takes place over 24 hours.
# Author: Ashes999 (ashes999@yahoo.com)
# Version: 1.0

class Window_SaveFile
  def draw_playtime(x, y, width, align)
      contents = {}
      
      filename = DataManager.make_filename(@file_index)
      
      if File.exist?(filename)
        File.open(filename, "rb") do |file|
          Marshal.load(file)
          contents = Marshal.load(file)
        end
        
        game_time = contents[:gametime]
        hour = game_time.hour
        am_pm = hour < 12 ? "AM" : "PM"
        hour -= 12 if hour > 12
        hour = 12 if hour == 0 # midnight is 12am, not 0am
        
        minute = game_time.min
        minute = "0#{minute}" if (minute < 10)
        game_time_string = "#{hour}:#{minute} #{am_pm}"
        
        draw_text(x, y, width, line_height, game_time_string, 2)
      end
  end
end