FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
	sequence(:nickname)  { |n| "person#{n}" }
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end
  
  factory :workout do
    name "Lorem ipsum"
	log "Dolor sit amet"
    user
  end
end