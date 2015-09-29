class Activities
	 attr_accessor :activitie_name, :date, :start_time, :end_time
   def initialize (activitie_name, date, start_time, end_time )
    @activitie_name = activitie_name
    @date = date
    @start_time = start_time
    @end_time = end_time
   end
end

