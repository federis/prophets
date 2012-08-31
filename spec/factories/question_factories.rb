FactoryGirl.define do
  factory :question do
    sequence(:content) { |i| "question #{i}" }
    desc ""
    league
    user

    after(:build) do |question, evaluator|
      unless evaluator.approved_at.nil?
        question.stub(:approved_at_changed?).and_return(false)
      end
    end

    after(:create) do |question, evaluator|
      unless evaluator.approved_at.nil?
        question.unstub(:approved_at_changed?)
      end
    end

    factory :question_with_answers do
      ignore do
        answer_count 3
      end

      after(:create) do |question, evaluator|
        FactoryGirl.create_list(:answer, evaluator.answer_count, :question => question, :user => question.user, :initial_probability => 1.0/evaluator.answer_count)
      end
    end
  end
end
