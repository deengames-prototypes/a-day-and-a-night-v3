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

# Capture running the game
Logger.log("---------- Started a new session ----------")

# Capture when the user shuts down (Alt-F4 etc. can't be captured)
module SceneManager 

  class << self
    alias :adaan_exit :exit
  end
  
  def self.exit
    Logger.log("---------- Finished session ----------")
    adaan_exit    
  end
end

# Capture when the user goes to/from the achievements scene
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

# Capture when the user enters/exits a battle, and what the outcome was.
module BattleManager
  class << self
    alias :pa_battle_start :battle_start
    alias :pa_process_victory :process_victory
    alias :pa_process_defeat :process_defeat
    alias :pa_process_escape :process_escape
  end
  
  def self.battle_start
    Logger.log("! Battle: #{$game_troop.enemy_names}")
    pa_battle_start
  end
  
  def self.process_victory    
    Logger.log("! Player won")
    pa_process_victory
  end
  
  def self.process_defeat
    Logger.log("! Player lost")
    pa_process_defeat
  end
  
  def self.process_escape
    Logger.log("! Player escaped")
    pa_process_escape
  end  
end

# Capture when the user engages a store and buys something
class Scene_Shop
  
  alias :pa_start :start
  alias :pa_do_buy :do_buy
  
  def start
    pa_start
    Logger.log("$ Entered shop")
  end
  
  
  def do_buy(number)
    pa_do_buy(number)
    Logger.log("Bought #{number} of #{@item.name}")
  end
end

# Capture game over, including points totals
class Scene_Gameover
  alias :pa_start :start
  
  def start
    pa_start
  
    points = PointsSystem.get_points_scored    
    good_deeds = points.select { |p| p.points >= 0 }
    positive_points = 0
    good_deeds.each do |p|
      positive_points += p.points
    end
    
    bad_deeds = points.select { |p| p.points < 0 }
    negative_points = 0
    bad_deeds.each do |p|
      negative_points += p.points
    end
    
    
    time = "#{GameTime.hour?}:#{GameTime.min?}"
    play_time = $game_system.playtime_s
    
    Logger.log("Game over at #{time} after #{play_time}; #{positive_points} vs #{negative_points}")
  end
end