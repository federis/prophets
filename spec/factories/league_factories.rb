FactoryGirl.define do
  factory :league do
    sequence(:name) { |i| "League #{i}" }
    priv false
    user

    ignore do
      member nil
      admin nil
    end

    factory :league_with_member do
      after(:create) do |league, evaluator|
        FactoryGirl.create(:membership, :user => evaluator.member, :league => league)
      end
    end

    factory :league_with_admin do
      after(:create) do |league, evaluator|
        FactoryGirl.create(:membership, :user => evaluator.admin, :league => league, :role => Membership::ROLES[:admin])
      end
    end
  end
end
