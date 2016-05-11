API_ROOT = 'Scripts/vx-ace-api'
require 'Scripts/vx-ace-api/vx_ace_api'
require 'Scripts/achievements'
require 'Scripts/custom_save_system'

AchievementManager.initialize
throw "HI: #{AchievementManager.achieved}"
