FactoryGirl.define do
  factory :answer do
    sequence(:content) { |i| "answer #{i}" }
    question
    user
    initial_probability 0.2
  end
end
