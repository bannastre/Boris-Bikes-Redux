require 'docking_station'

describe DockingStation do
  before(:each) do
    @bike = instance_double("Bike", :working => true)
    @broken_bike = instance_double("Bike", :working => false)
    @max_capacity = DockingStation::MAX_CAPACITY
  end
  
  it { is_expected.to be_a(DockingStation) }

  it { is_expected.to respond_to(:release_bike) }

  it { is_expected.to respond_to(:show_docked_bikes) }

  it { is_expected.to respond_to(:dock_bike) }

  it { is_expected.to respond_to(:capacity) }
  
  it 'can release a working bike' do
    subject.dock_bike(@bike)
    expect(subject.release_bike(@bike).working).to eql(true)
  end

  it 'knows the bikes that are docked' do
    expect(subject.show_docked_bikes).to eql([])
  end

  it 'adds docked bikes to the list of bikes that are docked' do
    subject.dock_bike(@bike)
    expect(subject.show_docked_bikes).to eql([@bike])
  end

  it 'does not release a bike if there are none available' do
    expect { subject.release_bike(@bike) }.to raise_error('No bikes available')
  end

  it 'is initiated with a default capacity of 20' do
    expect(subject.capacity).to eql(@max_capacity)
  end

  it "won't accept any more bikes if the DS is at max capacity" do
    @max_capacity.times { subject.dock_bike(@bike) }
    expect { subject.dock_bike(@bike) }.to raise_error('Docking Station at Capacity')
  end

  it "won't release broken bikes" do
    subject.dock_bike(@broken_bike)
    expect { subject.release_bike(@broken_bike) }.to raise_error('No working bikes available')
  end
end