# Proton Analytics isn't ready yet. For now, just log interesting things to the log file.
# This file captures all the overrides, callbacks, etc. to accomplish that, as well as
# exposing easy calls for other stuff (like choices).

# Capture all points
PointsSystem.on_add_points(Proc.new do |event, score|
  Logger.log("#{score} point(s): #{event}")
end)

# Capture any achievements achieved
class Achievement
  alias :old_achieve :achieve
  
  def achieve
    old_achieve
    Logger.log("Achievement: #{@name}")
  end
end

# Capture any movements from map to map
# Load all maps into memory. They won't change during gameplay.
DataManager.load_normal_database # loads data into $data_mapinfos

class Game_Player
  alias :old_reserve_transfer :reserve_transfer
  
  # When moving from map to map
  def reserve_transfer(map_id, x, y, d = 2)
    old_reserve_transfer(map_id, x, y, d)
    Logger.log("Change map to: #{$data_mapinfos[map_id].name}")
  end
end

# Capture new game and load game
module DataManager
  class << self
    alias :pa_setup_new_game :setup_new_game
    alias :pa_extract_save_contents :extract_save_contents
  end
  
  def self.setup_new_game
    pa_setup_new_game
    Logger.log("***** Started a new game *****");
  end
  
  def self.extract_save_contents(contents)
    pa_extract_save_contents(contents)
    Logger.log("*** Loaded a save game ***")
  end
end

Logger.log("---------- Started a new session ----------")

# Log when the user shuts down (Alt-F4 etc. can't be trapped)
module SceneManager 

  class << self
    alias :adaan_exit :exit
  end
  
  def self.exit
    Logger.log("---------- Finished session ----------")
    adaan_exit    
  end
end

# Capture when the user goes to the achievements scene
class AchievementsScene
  alias :pa_start :start
  alias :pa_terminate :terminate
  
  def start
    pa_start
    Logger.log("* Checked achievements screen")
  end
  
  def terminate
    Logger.log("* Left achievements screen")
    pa_terminate    
  end
end