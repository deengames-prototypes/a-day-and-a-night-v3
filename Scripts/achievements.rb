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

    POPUP_WIDTH = 200
    POPUP_HEIGHT = 100
    
    attr_accessor :name, :description, :details
    attr_reader :is_achieved
    
    def initialize(name, description, details)
        @name = name
        @description = description
        @details = details
    end
        
    def achieve
        @is_achieved = true
        AchievementManager.save
        play_sound
        show_popup
        close_popup_after(1)
    end
    
    def play_sound
        Audio.se_play("Audio/SE/Shop", 80, 100)
    end
    
    def show_popup        
        @popup = Window_Base.new(POPUP_WIDTH, POPUP_HEIGHT, 0, 0)
        @popup.create_contents
        @popup.z = 9999

        bitmap = Bitmap.new(self.image)
        x = y = 0
        @popup.contents.blt(x, y, bitmap, Rect.new(0, 0, bitmap.width, bitmap.height))
    end
    
    def image
        return "Graphics/Pictures/Achievements/#{name.gsub(' ', '-')}.png"
    end
    
    private
    
    def close_popup_after(seconds)
        # Assume 60FPS, as is typical of VXA
        frames = seconds * 60
        #yield(frames)
        #@popup.close unless @popup.nil?
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
