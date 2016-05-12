###
# Achievements live across all games. They're also associated with fancy images and such.
# TODO: this is still very, very rough.
###

# Everything's static. It's easier that way.
class AchievementManager
    ACHIEVEMENTS_FILE = 'achievements.dat'
    @@achievements = []
    
    def self.initialize(default_achievements)
        if File.exist?(ACHIEVEMENTS_FILE)
            @@achievements = Serializer.deserialize(ACHIEVEMENTS_FILE)
        end
        
        @@achievements = default_achievements if @@achievements.nil? || achievements == []        
        Logger.log "Achievements are #{@@achievements}"
    end
    
    def self.save
        Serializer.serialize(AchievementManager.achievements, ACHIEVEMENTS_FILE)                
    end
    
    def self.achievements
        return @@achievements
    end
end

# An achievement
class Achievement

    attr_accessor :name, :description, :details
    attr_reader :is_achieved
    
    def initialize(name, description, details)
        @name = name
        @description = description
        @details = details
    end
        
    def achieve
        return if @is_achieved == true
        @is_achieved = true
        AchievementManager.save
        play_sound
        show_popup
    end
    
    def play_sound
        Audio.se_play("Audio/SE/Shop", 80, 100)
    end
    
    def show_popup        
        $game_map.interpreter.event_window_add_text("Achievement unlocked: #{self.name}")
        $game_map.interpreter.event_window_clear_text
    end
end

# A list of events, and what "time" they occurred (in ticks). Use these to decide
# what achievements to grant the user. 
class EventRecorder
    attr_accessor :events
    
    def note_event(name)
        # time = now_in_ticks
        @events << Event.new(name)
    end
    
    def has?(name)
        to_return = []
        @events.each do |e|
            to_return << e if e.name.downcase == name.downcase
        end
        return to_return
    end
end

# An event. Has a name and a time. (Time is in ticks so that if you save, quit, and reload
# the next day, you can still achieve achievements that need to be done relatively quickly).
class Event
    attr_accessor :name, :achieved_on_ticks
    
    def new(name, time)
        @name = name
        @achieved_on_ticks = time
    end
end

### Region: UI


class AchievementsScene < Scene_Base
    # Three windows:
    # 1) Thin top window (achievement name and description))
    # 2) Thin bottom window (achievement details)
    # 3) Middle window (images, keyboard to select)
    def start
        super
        @summary_window = AchievementSummaryWindow.new
        @details_window = AchievementDetailsWindow.new
        @selection_window = AchievementsSelectionWindow.new(@summary_window, @details_window)
        @selection_window.set_handler(:cancel, method(:return_scene))
        
        @summary_window.viewport = @viewport
        @details_window.viewport = @viewport
        @selection_window.viewport = @viewport
    end
end

class AchievementSummaryWindow < Window_Selectable
    def initialize
        super(0, 0, Graphics.width, 64)
    end
end

class AchievementsSelectionWindow < Window_Command

    def initialize(summary_window, details_window)
        @summary_window = summary_window
        @details_window = details_window
        super(0, 64)
    end
    
    def make_command_list
        super
        AchievementManager.achievements.each do |a|
          add_command(a.name, a.name.gsub(' ', '_').to_sym) if a.is_achieved     
        end
    end
    
    def window_width
        return Graphics.width
    end
    
    def window_height
        return Graphics.height - 128 - 64
    end
    
    # Run when the selected index changes
    def index=(index)    
        super
        achievement = AchievementManager.achievements[index]
        @summary_window.refresh # clears the old text        
        @summary_window.draw_text_ex(0, 0, "#{achievement.name}: #{achievement.description}")

        @details_window.refresh # clears the old text            
        @details_window.draw_text_ex(0, 0, achievement.details)
    end
end

class AchievementDetailsWindow < Window_Selectable
    def initialize
        super(0, Graphics.height - 128, Graphics.width, 128)
    end
end

### End region
