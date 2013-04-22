FactoryGirl.define do
  factory :activity do
    league

    trait :bet_created do
      activity_type Activity::TYPES[:bet_created]
      association :feedable, factory: :bet
      content "User bet $100"
    end

    trait :bet_payout do
      activity_type Activity::TYPES[:bet_payout]
      association :feedable, factory: :bet
      content "User won $100"
    end

    trait :question_published do
      activity_type Activity::TYPES[:question_published]
      association :feedable, factory: :question
      content "Question was published"
    end
  end
end
