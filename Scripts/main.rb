API_ROOT = 'Scripts/vx-ace-api'
require 'Scripts/vx-ace-api/vx_ace_api'
require 'Scripts/achievements'
require 'Scripts/image_title_menu'
require 'Scripts/extensions/Event_Window'
require 'Scripts/extensions/custom_save_system'
require 'Scripts/extensions/points_system'
require 'Scripts/extensions/points_system_game_over_screen'
require 'Scripts/extensions/advanced_game_time'
require 'Scripts/extensions/script_event_page_conditions'
require 'Scripts/extensions/swimming'
require 'Scripts/extensions/lemony_sounds'
require 'Scripts/extensions/lemonys_current_fps'

DEFAULT_ACHIEVEMENTS = [
    Achievement.new("Khalid bin Walid", "Survive ten battles", "Placeholder achievement"),
    Achievement.new("Son of Adam", "Commit your first sin", "Every son of Adam sins and the best are those who repent often")
]

AchievementManager.initialize(DEFAULT_ACHIEVEMENTS)

class AdaanV3
  STARTED_SWIMMING_VARIABLE = 1
  DROWN_AFTER_SECONDS = 15
  
  def self.is_game_over?
    # One day later and >= 5am
    return GameTime.day? > 1 && GameTime.hour? >= 5
  end
  
  def self.is_drowned?
    Logger.log("HI! #{$game_variables[STARTED_SWIMMING_VARIABLE]} variables");
    # 0 is the default value for variables that we didn't use yet.
    return $game_variables[STARTED_SWIMMING_VARIABLE] != 0 && Time.new - $game_variables[STARTED_SWIMMING_VARIABLE] >= DROWN_AFTER_SECONDS
  end
  
  def self.is_salah_time?    
    return true if GameTime.hour? == 5 && GameTime.min? >= 30 && GameTime.min? <= 39 # Fajr
    return true if GameTime.hour? == 13 && GameTime.min? >= 15 &&  GameTime.min? <= 24 # Dhur    
    return true if GameTime.hour? == 17 && GameTime.min? >= 20 && GameTime.min? <= 29 # Asr
    return true if GameTime.hour? == 20 && GameTime.min? >= 43 && GameTime.min? <= 53 # Maghrib
    return true if GameTime.hour? == 22 && GameTime.min? >= 25 && GameTime.min? <= 34 # Isha
    return false
  end
end