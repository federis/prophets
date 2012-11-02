object @question
attributes :id, :content, :desc, :league_id, :user_id, :approver_id, :approved_at, :bet_count, :betting_closes_at, :created_at, :updated_at
node(:comment_count){|question| question.comments.count }

if @include_answers
  child :answers do
    extends "answers/show"
  end
end
