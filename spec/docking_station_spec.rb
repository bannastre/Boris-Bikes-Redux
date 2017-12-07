require 'docking_station'

describe DockingStation do
  it "is polite" do
    expect(subject.say_hello).to eql('Hello World!')
  end
end