FactoryGirl.define do
  factory :league_membership do
    sequence(:name) { |i| "League Membership #{i}" }
    user
    league
    role LeagueMembership::ROLES[:member]
  end
end
