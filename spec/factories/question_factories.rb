FactoryGirl.define do
  factory :question do
    sequence(:content) { |i| "question #{i}" }
    desc ""
    league
    user
    association :approver, :factory => :user
  end
end
