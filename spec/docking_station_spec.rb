require 'docking_station'

describe DockingStation do
  it 'is polite' do
    expect(subject.say_hello).to eql('Hello World!')
  end

  it { is_expected.to respond_to(:release_bike) }

  it { is_expected.to respond_to(:show_docked_bikes) }

  it { is_expected.to respond_to(:dock_bike) }

  it 'can release a new bike' do
    expect(subject.release_bike.working?).to eql(true)
  end

  it 'releases a working bike' do
    expect(subject.release_bike).to be_a(Bike)
  end

  it 'knows the bikes that are docked' do
    expect(subject.show_docked_bikes).to eql([])
  end

  it 'adds docked bikes to the list of bikes that are docked' do
    bike = Bike.new
    subject.dock_bike(bike)
    expect(subject.show_docked_bikes).to eql([bike])
  end

end