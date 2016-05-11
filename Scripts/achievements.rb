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
            contents = File.read(ACHIEVEMENTS_FILE)
            @@achievements = Serializer.deserialize(contents)
        end
        
        @@achievements = default_achievements if @@achievements.nil? || achievements == {}        
        Logger.log "Achievements are #{@@achievements}"
    end
    
    def self.save
        serialized = Serializer.serialize(AchievementManager.achievements)        
        File.write(ACHIEVEMENTS_FILE, serialized)       
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
        @popup = nil
    end
        
    def achieve
        @is_achieved = true
        AchievementManager.save(self)
        play_sound
        show_popup
        close_popup_after(1)
    end
    
    def play_sound
        Audio.se_play("Audio/SE/Shop", 80, 100)
    end
    
    def show_popup        
        @popup = Window_Base.new(POPUP_WIDTH, POPUP_HEIGHT, 0, 0)
        @popup.z = 9999
        @popup.refresh

        bitmap = Cache.picture(self.image)
        rect = Rect.new(0, 0, POPUP_WIDTH, POPUP_HEIGHT)
        target = Rect.new(0, 0, POPUP_WIDTH, POPUP_HEIGHT)
        contents.stretch_blt(target, bitmap, rect, 255)
    end
    
    private
    
    def image
        return "Graphics/#{name.gsub(' ', '-')}.png"
    end
    
    def close_popup_after(seconds)
        # Assume 60FPS, as is typical of VXA
        frames = seconds * 60
        yield(frames)
        @popup.close unless @popup.nil?
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
