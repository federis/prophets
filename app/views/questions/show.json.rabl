object @question
attributes :id, :content, :desc, :league_id, :user_id, :approver_id, :approved_at, :bets_count, :comments_count, :betting_closes_at, :completed_at, :created_at, :updated_at

if @include_answers
  child :answers do
    extends "answers/show"
  end
end
