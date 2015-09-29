require_relative 'activities'
class Charla
	attr_accessor :speaker
	 def initialize(activitie_name, start_time, end_time, speaker)
    super
    @speaker = speaker
   end