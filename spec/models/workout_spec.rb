require 'spec_helper'

describe Workout do
  let(:user) { FactoryGirl.create(:user) }
  before { @workout = user.workouts.build(name: "Lorem ipsum", log: "dolor sit amet") }

  subject { @workout }

  it { should respond_to(:name) }
  it { should respond_to(:log) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @workout.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank name" do
    before { @workout.name = " " }
    it { should_not be_valid }
  end
  
  describe "with blank log" do
    before { @workout.log = " " }
    it { should_not be_valid }
  end

  describe "with name that is too long" do
    before { @workout.name = "a" * 141 }
    it { should_not be_valid }
  end
end
