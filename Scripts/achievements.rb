###
# Achievements live across all games. They're also associated with fancy images and such.
# TODO: this is still very, very rough.
###
module Achievements
	# An achievement	
	class Achievement
		attr_accessor :name, :description, :details
		
		private
		
		attr_accessor :is_achieved
		
		def achieve
			this.is_achieved = true;
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
end