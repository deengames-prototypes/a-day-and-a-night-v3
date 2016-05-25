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
    Achievement.new("Son of Adam", "Commit your first sin", "Every son of Adam sins and the best are those who repent often (at-tawwaboon). [Tirmidhi]"),
    Achievement.new("Seeker of Knowledge", "Seek a path of religious knowledge", "Whoever follows a path to seek knowledge, Allah will make the path of Jannah easy to him. The angels lower their wings over the seeker of knowledge [...] even the fish in the depth of the oceans seek forgiveness for him. [Abu Dawud]"),
    Achievement.new("Drowned", "Discover a path to martyrdom", "Five are regarded as martyrs: They are those who die because of plague, abdominal disease, drowning, are crushed to death, and the martyrs in Allah's cause. [Bukhari]"),
    Achievement.new("Nafsun Lawwamah", "Flip-flop between good and bad deeds", "An-nafs al-lawwamah means the soul that flip-flops between good and bad deeds, and the soul that admonishes/reproaches itself after it commits bad deeds.")
]

AchievementManager.initialize(DEFAULT_ACHIEVEMENTS)

PointsSystem.on_add_points(Proc.new do |event, score|
  # If this is the first sin, get the Son of Adam achievement.
  all_points = PointsSystem.get_points_scored
  if all_points.select { |p| p.points < 0 }.length == 1 # this is the only sin
    AchievementManager.achievements.select { |a| a.name == 'Son of Adam' }.first.achieve
  end
  
  # Look at the last four deeds. If it's good/bad/good/bad or bad/good/bad/good,
  # award the An-Nafsun Al-Lawwamah achievement.
  if (all_points.length >= 4)
    last_four = all_points[-4..-1]
    award = last_four[0].points < 0 && last_four[1].points > 0 && last_four[2].points < 0 && last_four[3].points > 0
    award ||= last_four[0].points > 0 && last_four[1].points < 0 && last_four[2].points > 0 && last_four[3].points < 0
    AchievementManager.achievements.select { |a| a.name == 'Nafsun Lawwamah' }.first.achieve if award
  end
end)

class AdaanV3
  STARTED_SWIMMING_VARIABLE = 1
  DROWN_AFTER_SECONDS = 15
  
  def self.is_game_over?
    # One day later and >= 5am
    return GameTime.day? > 1 && GameTime.hour? >= 5
  end
  
  def self.is_drowned?    
    # 0 is the default value for variables that we didn't use yet.
    return $game_variables[STARTED_SWIMMING_VARIABLE] != 0 && Time.new - $game_variables[STARTED_SWIMMING_VARIABLE] >= DROWN_AFTER_SECONDS
  end
  
  # returns the salah name whose time it is now, or nil
  def self.current_masjid_salah   
    return 'Fajr' if GameTime.hour? == 5 && GameTime.min? >= 30 && GameTime.min? <= 39
    return 'Dhur' if GameTime.hour? == 13 && GameTime.min? >= 15 &&  GameTime.min? <= 24    
    return 'Asr' if GameTime.hour? == 17 && GameTime.min? >= 20 && GameTime.min? <= 29
    return 'Maghrib' if GameTime.hour? == 20 && GameTime.min? >= 43 && GameTime.min? <= 53
    return 'Isha' if GameTime.hour? == 22 && GameTime.min? >= 25 && GameTime.min? <= 34 
    return nil
  end
  
  def self.is_salah_time?
    return !current_masjid_salah.nil?
  end
end