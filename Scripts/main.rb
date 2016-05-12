API_ROOT = 'Scripts/vx-ace-api'
require 'Scripts/vx-ace-api/vx_ace_api'
require 'Scripts/achievements'
require 'Scripts/custom_save_system'
require 'Scripts/image_title_menu'
require 'Scripts/extensions/Event_Window'

DEFAULT_ACHIEVEMENTS = [
    Achievement.new("Khalid bin Walid", "Survive ten battles", "Placeholder achievement"),
    Achievement.new("Son of Adam", "Commit your first sin", "Every son of Adam sins and the best are those who repent often")
]

AchievementManager.initialize(DEFAULT_ACHIEVEMENTS)

Logger.log(Bitmap.instance_methods)