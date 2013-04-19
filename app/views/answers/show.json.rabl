object @answer
attributes :id, :content, :question_id, :user_id, :initial_probability, :current_probability, :bet_total, :bets_count, :correct, :correctness_known_at, :created_at, :updated_at, :judged_at, :judge_id

if @include_question
  child :question do
    extends "questions/show"
  end
end