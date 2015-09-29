require_relative 'activities'
class Taller < Activities
	attr_accessor :requierements
	 def initialize(activitie_name, date, start_time, end_time, requierements)
    super
    @requierements = requierements
   end
 end