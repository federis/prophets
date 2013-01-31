FactoryGirl.define do
  factory :question do
    sequence(:content) { |i| "question #{i}" }
    desc ""
    league
    user
    betting_closes_at { 1.month.from_now }
    approved_at { 1.day.ago }
    approver

    before(:create) do |question, evaluator|
      question.stub(:approved?).and_return(false)
      question.stub(:check_answer_initial_probabilities).and_return(true)
      question.stub(:ensure_betting_closes_in_future).and_return(true)
    end

    after(:create) do |question, evaluator|
      question.unstub(:approved?)
      question.unstub(:check_answer_initial_probabilities)
      question.unstub(:ensure_betting_closes_in_future)
    end

    trait :unapproved do
      approved_at nil
      approver nil
    end

    trait :with_answers do
      ignore do
        answers_count 3
      end

      after(:create) do |question, evaluator|
        FactoryGirl.create_list(:answer, evaluator.answers_count, :question => question, :user => question.user, :initial_probability => 1.0/evaluator.answers_count)
      end
    end
  end
end
