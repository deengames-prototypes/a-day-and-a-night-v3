###
# Achievements live across all games. They're also associated with fancy images and such.
# TODO: this is still very, very rough.
###

# Everything's static. It's easier that way.
class AchievementManager
  ACHIEVEMENTS_FILE = 'achievements.dat'
  @@achieved = []
  
  def self.initialize
    if File.exist?(ACHIEVEMENTS_FILE)
      contents = File.read(ACHIEVEMENTS_FILE)
      @@achieved = Serializer.deserialize(contents) || []
    end
  end
  
  def self.save(a)
    AchievementManager.achieved << a
    serialized = Serializer.serialize(AchievementManager.achieved)
    
    f = File.open(ACHIEVEMENTS_FILE, 'w')    
    f.write(serialized)
    f.close
  end
  
  def self.achieved
    return @@achieved
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
    @is_achieved = true
    AchievementManager.save(self)
    # Play sound
    # Show pop-up    
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
