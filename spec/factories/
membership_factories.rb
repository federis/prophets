FactoryGirl.define do
  factory :membership do
    sequence(:name) { |i| "Membership #{i}" }
    user
    league
    role Membership::ROLES[:member]
  end
end
