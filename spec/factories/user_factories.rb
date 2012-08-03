FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@example.com" }
    password "password"
    sequence(:name) { |i| "User #{i}" }
  end
end
