FactoryGirl.define do
  factory :comment do
    sequence(:comment) { |i| "comment #{i}" }
    user

    trait :for_question do
      association :commentable, factory: :question
    end

    trait :for_league do
      association :commentable, factory: :league
    end
  end
end
