require 'bike'

describe Bike do
  it { is_expected.to respond_to(:working) }

  it 'is working by default' do
    expect(subject.working).to eql true
  end

  it 'can be reported broken' do
    subject.report_broken
    expect(subject.working).to eql false
  end
end
