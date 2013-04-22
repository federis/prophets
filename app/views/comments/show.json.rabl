object @comment
attributes :id, :user_id, :comment, :created_at, :updated_at
node(:league_id){|comment| comment.commentable_type == "League" ? comment.commentable_id : nil }
node(:question_id){|comment| comment.commentable_type == "Question" ? comment.commentable_id : nil } 
node(:bet_id){|comment| comment.commentable_type == "Bet" ? comment.commentable_id : nil } 
node(:user_name){|comment| comment.user.name }