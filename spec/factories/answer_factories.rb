FactoryGirl.define do
  factory :answer do
    sequence(:content) { |i| "answer #{i}" }
    question
    user
  end
end
