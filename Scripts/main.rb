API_ROOT = 'Scripts/vx-ace-api'
require 'Scripts/vx-ace-api/vx_ace_api'
require 'Scripts/achievements'
require 'Scripts/image_title_menu'
require 'Scripts/MenuChanger.rb'
require 'Scripts/extensions/Event_Window'
require 'Scripts/extensions/custom_save_system'
require 'Scripts/extensions/points_system'
require 'Scripts/extensions/points_system_game_over_screen'
require 'Scripts/extensions/advanced_game_time'
require 'Scripts/extensions/script_event_page_conditions'
require 'Scripts/extensions/swimming'
require 'Scripts/extensions/lemony_sounds'
require 'Scripts/extensions/lemonys_current_fps'
require 'Scripts/extensions/super-simple-mouse-script'
require 'Scripts/extensions/system_options'
require 'Scripts/extensions/Victor-Engine-Basic-Module'
require 'Scripts/extensions/Victor-Engine-Light-Effects'
require 'Scripts/proton_analytics'

DEFAULT_ACHIEVEMENTS = [

    Achievement.new("Son of Adam", "Commit your first sin", "Every son of Adam sins and the best are those who repent often (at-tawwaboon). [Tirmidhi]"),
    Achievement.new("Seeker of Knowledge", "Seek a path of religious knowledge", "Whoever follows a path to seek knowledge, Allah will make the path of Jannah easy to him. The angels lower their wings over the seeker of knowledge [...] even the fish in the depth of the oceans seek forgiveness for him. [Abu Dawud]"),
    Achievement.new("Shaheed", "Discover a path to martyrdom", "Five are regarded as martyrs: They are those who die because of plague, abdominal disease, drowning, are crushed to death, and the martyrs in Allah's cause. [Bukhari]"),
    Achievement.new("Nafsun Lawwamah", "Flip-flop between good and bad deeds", "An-nafs al-lawwamah means both the soul that flip-flops between good and bad deeds, and the soul that admonishes/reproaches itself after it commits bad deeds."),
	
    Achievement.new("Heart Attached to the Masjid", "Pray 5x in the masjid in a day", "Seven types of people will receive Allah's shade on the day of Resurrection, where there is no shade except His shade. One of them is a person who's heart is attached to the masjid. [Bukhari and Muslim]"),
    Achievement.new("Past and Present", "Rediscover why you're here", "Except for those who repent, believe and do righteous work. For them Allah will replace their evil deeds with good. And ever is Allah Forgiving and Merciful. [Surat Al-Furqan, 25:70]"),
    Achievement.new("You Monster!", "Side with poachers", "A woman entered the Fire because of a cat which she had tied, neither giving it food nor setting it free to eat from the vermin of the earth. [Bukhari]"),
    Achievement.new("Animal Saviour", "Save an animal's life", "A dog was going round a well and was about to die of thirst. A prostitute saw it, took off her shoe, and use it to draw out water for the dog. Allah forgave her because of that good deed. [Bukhari]"),
	
    Achievement.new("Magician's Apprentice", "Commit shirk by sacrificing to a jinn", "Whoever ties a knot and blows on it, he has practiced magic; and whoever practices magic, he has committed shirk; and whoever hangs up something (as an amulet) will be entrusted to it (to protect him). [An-Nasaai]"),
    Achievement.new("Footsteps of Ibrahim", "Frame one statue for destroying others", "Prophet Ibrahim broke his people's idols into fragments, except a large one, and blamed it for the deed. His people almost recanted on their beliefs, but instead decided to burn him alive. [Surah Anbiyaa, 21:57-68]"),
    Achievement.new("Kill Yourself Forever", "Commit suicide purposely", "Whoever purposely throws himself from a mountain and kills himself, or drinks poison and kills himself, or kills himself with an iron weapon, will keep repeating that action in the Fire, forever. [Bukhari]"),
    Achievement.new("Thief", "Steal everything in the inn", "A man was killed by an arrow during Khaibar. The people said: 'Congratulations [on martyrdom]!' but the Messenger of Allah said: 'No, by Allah! The cloak that he took from the spoils of war is burning him with fire.' [An-Nasaai]")
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

  # Look at the last five salahs in the masjid. If we have fajr/dhur/asr/maghrib/isha,
  # award the muallaq al-quloob achievement.
  if all_points.length >= 5
    salawaat = all_points.select { |p| p.event.downcase.include?('in the masjid') }
    if salawaat.length >= 5
      last_five = salawaat[-5..-1]
      # most recent five include each of the five salawaat
      award = last_five.any? { |s| s.event.include?('Fajr') } && last_five.any? { |s| s.event.include?('Dhur') } && last_five.any? { |s| s.event.include?('Asr') } && last_five.any? { |s| s.event.include?('Maghrib') } && last_five.any? { |s| s.event.include?('Isha') }
      AchievementManager.achievements.select { |a| a.name == 'Heart Attached to the Masjid' }.first.achieve if award
    end
  end
end)

class AdaanV3
  STARTED_SWIMMING_VARIABLE = 1
  DROWN_AFTER_SECONDS = 15
  VARIABLE_WITH_FLASHBACK_NUMBER = 2
  
  # Map data. Each map has an ID (VXA ID), and X/Y position to teleport the player to.
  FLASHBACK_MAPS = [
    { :id => 6, :x => 8, :y => 12 },
    { :id => 7, :x => 8, :y => 12 },
	{ :id => 11, :x => 8, :y => 6 },
  ]

  def self.is_game_over?
    # one day later and >= 5am
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
  
  # Teleport you to the map with the appropriate flashback number (variable #2)
  def self.show_flashback
    @@source_map = {:id => $game_map.map_id, :x => $game_player.x, :y => $game_player.y }    
    map_data = FLASHBACK_MAPS[$game_variables[VARIABLE_WITH_FLASHBACK_NUMBER]]
    
    GameTime.notime(true) # pause time
    GameTime.clock?(false)
    
    if !map_data.nil?
      $game_map.screen.start_tone_change(Tone.new(0, 0, 0, 255), 30) # grey out    
      transfer_to(map_data)
    end
  end
  
  def self.end_flashback  
    $game_map.screen.start_tone_change(Tone.new(0, 0, 0, 0), 30) # undo grey-out
    transfer_to(@@source_map)    
    
    GameTime.notime(false) # resume time
    GameTime.clock?(true)
  end
  
  private
  
  def self.transfer_to(map_data)
    map_id = map_data[:id]
    x = map_data[:x]
    y = map_data[:y]

    $game_player.reserve_transfer(map_id, x, y)
    Fiber.yield while $game_player.transfer?
  end
end
