FactoryGirl.define do
  factory :bet do
    amount 2
    probability 0.2
    answer
    membership

    trait(:winner){ payout 10 }
    trait(:loser){ payout 0 }
    trait(:invalidated) do
      invalidated_at { Time.now }
    end

  end
end
