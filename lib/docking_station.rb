require_relative 'bike'

class DockingStation

  def initialize
    @docked_bikes = []
  end

  def release_bike
    @docked_bikes.empty? ? raise('No bikes available') : Bike.new
  end

  def show_docked_bikes
    @docked_bikes
  end

  def dock_bike(bike)
    @docked_bikes.push(bike)
  end

end