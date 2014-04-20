require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar",
					 nickname: "mruser")
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:workouts) }
  it { should respond_to(:feed) }
  it { should respond_to(:nickname) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end
  
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end
  
  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end
  
  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end
  
  describe "when nickname is too long" do
    before { @user.nickname = "a" * 51 }
    it { should_not be_valid }
  end
  
  describe "when nickname is too short" do
    before { @user.nickname = "a" * 3 }
    it { should_not be_valid }
  end
  
  describe "when nickname is not present" do
    before { @user.nickname = " " }
    it { should_not be_valid }
  end
  
  describe "when nickname format is invalid" do
    it "should be invalid" do
      nicknames = ["u ser", "u/ser", "u\\ser", "u*ser", "u'ser", "u\"ser",
				   "u.ser", "u,ser", "u;ser", "u:ser"]
      nicknames.each do |invalid_nickname|
        @user.nickname = invalid_nickname
        expect(@user).not_to be_valid
      end
    end
  end
  
  describe "when nickname format is valid" do
    it "should be valid" do
      nicknames = %w[user A_US-ER user9 UuSsEeRr]
      nicknames.each do |valid_nickname|
        @user.nickname = valid_nickname
        expect(@user).to be_valid
      end
    end
  end

  describe "when nickname is already taken" do
    before do
      user_with_same_nickname = @user.dup
      user_with_same_nickname.nickname = @user.nickname.upcase
      user_with_same_nickname.save
    end

    it { should_not be_valid }
  end

  describe "nickname with mixed case" do
    let(:mixed_case_nickname) { "ExAMPle" }

    it "should be saved as all lower-case" do
      @user.nickname = mixed_case_nickname
      @user.save
      expect(@user.reload.nickname).to eq mixed_case_nickname.downcase
    end
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eq mixed_case_email.downcase
    end
  end
  
  describe "when password is not present" do
    before do
      @user = User.new(name: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
  
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "workout associations" do

    before { @user.save }
    let!(:older_workout) do
      FactoryGirl.create(:workout, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_workout) do
      FactoryGirl.create(:workout, user: @user, created_at: 1.hour.ago)
    end

    it "should have the right workouts in the right order" do
      expect(@user.workouts.to_a).to eq [newer_workout, older_workout]
    end
	
	it "should destroy associated workouts" do
      workouts = @user.workouts.to_a
      @user.destroy
      expect(workouts).not_to be_empty
      workouts.each do |workout|
        expect(Workout.where(id: workout.id)).to be_empty
      end
    end
	
	describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:workout, user: FactoryGirl.create(:user))
      end

      its(:feed) { should include(newer_workout) }
      its(:feed) { should include(older_workout) }
      its(:feed) { should_not include(unfollowed_post) }
    end
  end
end

