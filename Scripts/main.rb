API_ROOT = 'Scripts/vx-ace-api'
require 'Scripts/vx-ace-api/vx_ace_api'
require 'Scripts/achievements'
require 'Scripts/image_title_menu'
require 'Scripts/extensions/Event_Window'
require 'Scripts/extensions/custom_save_system'
require 'Scripts/extensions/points_system'
require 'Scripts/extensions/points_system_game_over_screen'

DEFAULT_ACHIEVEMENTS = [
    Achievement.new("Khalid bin Walid", "Survive ten battles", "Placeholder achievement"),
    Achievement.new("Son of Adam", "Commit your first sin", "Every son of Adam sins and the best are those who repent often")
]

AchievementManager.initialize(DEFAULT_ACHIEVEMENTS)