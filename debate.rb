require_relative 'activities'
class Debate
  attr_accessor :speakers, :moderator 
   def intitialize(activitie_name, date, start_time, end_time, speakers, moderator)
    super
    @speakers = speakers
    @moderator = moderator
  end

end