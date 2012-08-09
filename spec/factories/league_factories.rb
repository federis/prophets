FactoryGirl.define do
  factory :league do
    sequence(:name) { |i| "League #{i}" }
    priv false
    user
  end
end
