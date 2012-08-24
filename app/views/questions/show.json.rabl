object @question
attributes :id, :content, :desc, :league_id, :user_id, :approver_id, :approved_at, :created_at, :updated_at

if params[:action] == "show"
  child :answers do
    extends "answers/show"
  end
end