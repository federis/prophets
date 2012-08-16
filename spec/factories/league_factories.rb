FactoryGirl.define do
  factory :league do
    sequence(:name) { |i| "League #{i}" }
    priv false
    user

    factory :league_with_member do
      after(:create) do |league, evaluator|
        FactoryGirl.create(:league_membership, :user => evaluator.user, :league => league)
      end
    end

    factory :league_with_admin do
      after(:create) do |league, evaluator|
        FactoryGirl.create(:league_membership, :user => evaluator.user, :league => league, :role => LeagueMembership::ROLES[:admin])
      end
    end
  end
end