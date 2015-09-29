require_relative 'activities'
require_relative 'taller'
require_relative 'charla'
require_relative 'debate'
class Event
	 attr_accessor :event_name, :start_date, :end_date, :activities
	 def initialize(name, start_date, end_date)
		@event_name = name
		@start_date = start_date
		@end_date = end_date
    @activities = []
   end
   def create_event(name, start_date, end_date)
    if start_date <= end_date
      "|ERROR| Problemas en las fechas."
    else
      Event.new(name, start_date, end_date)
   end

   def details
    "#{@event_name} (#{@start_date} al #{@end_date}"
   end

   def dates
   (@start_date..@end_date).to_a
   end
   
   def add_workshop(name, date, start_time, end_time, type, requeriments)
    inst = Taller.new(name, date, start_time, end_time, type, requeriments)
    @activities << inst
   end

   def add_talk(name, date, start_time, end_time, type, speaker)
    inst = Charla.new(name, date, start_time, end_time, type, speaker)
    @activities << inst
   end

   def add_debate(name, date, start_time, end_time, type, speakers, moderator)
    inst = Debate.new(name, date, start_time, end_time, type, speakers, moderator)
    @activities << inst
   end

