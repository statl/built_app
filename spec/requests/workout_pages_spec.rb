require 'spec_helper'

describe "Workout pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "workout creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a workout" do
        expect { click_button "Post" }.not_to change(Workout, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'workout_name', with: "Lorem ipsum" }
	  before { fill_in 'workout_log', with: "Dolor sit amet" }
      it "should create a workout" do
        expect { click_button "Post" }.to change(Workout, :count).by(1)
      end
    end
  end
  
  describe "workout destruction" do
    before { FactoryGirl.create(:workout, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a workout" do
        expect { click_link "delete" }.to change(Workout, :count).by(-1)
      end
    end
  end
end