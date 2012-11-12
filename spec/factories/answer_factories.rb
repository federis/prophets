FactoryGirl.define do
  factory :answer do
    sequence(:content) { |i| "answer #{i}" }
    question
    user
    initial_probability 0.2

    factory :answer_with_bets do
      ignore do
        bets_count 3
        bet_user nil
      end

      after(:create) do |answer, evaluator|
        user = evaluator.bet_user || answer.user
        membership = user.membership_in_league(answer.question.league) || FactoryGirl.create(:membership, :league => answer.question.league, :user => user)
        FactoryGirl.create_list(:bet, evaluator.bets_count, :answer => answer, :membership => membership)
      end
    end
  end
end
