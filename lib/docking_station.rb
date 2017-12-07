require_relative 'bike'

class DockingStation
  
  def initialize
    @docked_bikes = []
  end
  
  def say_hello
    'Hello World!'
  end

  def release_bike
    Bike.new
  end

  def show_docked_bikes
    @docked_bikes
  end

end