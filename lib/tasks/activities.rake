namespace :activities do
  task :update_comment_counts => :environment do
    puts "Updating comment counts"
    
    Activity.find_each do |activity|
      count = activity.feedable.try(:comments_count) || 0
      activity.update_attribute(:comments_count, count)
      puts "  #{activity.id} => #{count}"
    end
  end
end