###
# Achievements live across all games. They're also associated with fancy images and such.
# TODO: this is still very, very rough.
###

# Everything's static. It's easier that way.
class AchievementManager
    ACHIEVEMENTS_FILE = 'achievements.dat'
    @@achievements = {} # name (symbol) => achievement
    
    def self.initialize(default_achievements)
        if File.exist?(ACHIEVEMENTS_FILE)
            @@achievements = Serializer.deserialize(ACHIEVEMENTS_FILE)
        end
        
        @@achievements = default_achievements if @@achievements.nil? || achievements == {}        
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
        # TODO: makes debugging easier so ... return if @is_achieved == true
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
    
    def image
        # Uses Yanfly Engine Ace - Event Window
        return "Graphics/Pictures/Achievements/#{name.gsub(' ', '-')}.png"
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
