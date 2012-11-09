object @bet
attributes :id, :membership_id, :answer_id, :amount, :probability, :bonus, :payout, :created_at, :updated_at

if @include_answer
  child :answer do
    extends "answers/show"
  end
end