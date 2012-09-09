FactoryGirl.define do
  factory :answer do
    sequence(:content) { |i| "answer #{i}" }
    question
    user
    initial_probability 0.2

    factory :answer_with_bets do
      ignore do
        bet_count 3
        bet_user nil
      end

      after(:create) do |answer, evaluator|
        FactoryGirl.create_list(:bet, evaluator.bet_count, :answer => answer, :user => evaluator.bet_user || answer.user)
      end
    end
  end
end
