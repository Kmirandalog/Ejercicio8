class Event
	 attr_accessor :event_name, :start_date, :end_date, :activities
	 def initialize(name, start_date, end_date)
		@event_name = name
		@start_date = start_date
		@end_date = end_date
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
   