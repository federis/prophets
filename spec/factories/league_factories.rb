FactoryGirl.define do
  factory :league do
    sequence(:name) { |i| "League #{i}" }
    priv false
    user
    max_bet 1000
    initial_balance 10000

    trait :private do
      priv true
      password_digest "$2a$10$hRQ6pSt5H09rb0X5idSJrukNGn9UgD2s0v84MV4Wgyg2c0yLBhZfy" # abc123
    end

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
