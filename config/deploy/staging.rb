set :rails_env, 'production'

role :web, "your web-server here"
role :app, "your app-server here"
role :db,  "your primary db-server here", :primary => true
role :resque_worker, "something"