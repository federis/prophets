FactoryGirl.define do
  factory :question do
    sequence(:content) { |i| "question #{i}" }
    desc ""
    league
    user
    approver nil
  end
end
