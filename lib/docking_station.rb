require_relative 'bike'

class DockingStation
  
  MAX_CAPACITY = 20

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
    at_capacity ? raise('Docking Station at Capacity') : @docked_bikes.push(bike)
  end

  def capacity
    MAX_CAPACITY
  end

  private

  def at_capacity
    @docked_bikes.length >= MAX_CAPACITY
  end

end