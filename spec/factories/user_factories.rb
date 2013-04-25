FactoryGirl.define do
  factory :user, :aliases => [:approver] do
    sequence(:email) { |i| "user#{i}@example.com" }
    password "password"
    sequence(:name) { |i| "User #{i}" }
    sequence(:fb_uid){ |i| "#{i}" }
    sequence(:fb_token){ |i| "token-#{i}" }
    fb_token_expires_at { 1.month.from_now }
  end
end
