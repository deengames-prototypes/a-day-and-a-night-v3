API_ROOT = 'Scripts/vx-ace-api'
require 'Scripts/vx-ace-api/vx_ace_api'
require 'Scripts/achievements'
require 'Scripts/image_title_menu'
require 'Scripts/extensions/Event_Window'
require 'Scripts/extensions/custom_save_system'
require 'Scripts/extensions/points_system'
require 'Scripts/extensions/points_system_game_over_screen'
require 'Scripts/extensions/advanced_game_time'


DEFAULT_ACHIEVEMENTS = [
    Achievement.new("Khalid bin Walid", "Survive ten battles", "Placeholder achievement"),
    Achievement.new("Son of Adam", "Commit your first sin", "Every son of Adam sins and the best are those who repent often")
]

AchievementManager.initialize(DEFAULT_ACHIEVEMENTS)

class AdaanV3
  def self.is_game_over?
    # One day later and >= 5am
    return GameTime.day? > 1 && GameTime.hour? >= 5
  end
end