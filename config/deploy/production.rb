set :rails_env, 'production'

role :web, "192.81.211.10"
role :app, "192.81.211.10"
role :db,  "192.81.211.10", :primary => true
role :resque_worker, "192.81.211.10"