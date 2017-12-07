require_relative 'bike'

class DockingStation 
  def say_hello
    'Hello World!'
  end

  def release_bike
    Bike.new
  end
end