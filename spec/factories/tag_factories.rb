FactoryGirl.define do
  factory :tag, :class => ActsAsTaggableOn::Tag do
    sequence(:name) { |i| "tag#{i}" }
  end
end
