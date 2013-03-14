source 'https://rubygems.org'

gem 'rails', '3.2.11'

gem 'pg'
gem 'pg_search'

gem 'unicorn'
gem 'resque', '1.23.1'
gem 'grocer' # for push notifications
gem 'whenever'

gem 'devise', '~> 2.1'
gem 'omniauth-facebook'
gem 'cancan', '~>1.6'
gem 'bcrypt-ruby', '~> 3.0.0', :require => 'bcrypt'

gem 'rabl', '~>0.7'

gem 'koala'

gem 'acts_as_commentable', '3.0.1'
gem 'acts-as-taggable-on', '~> 2.3.1'

gem 'twitter-bootstrap-rails'
gem "therubyracer"
gem "less-rails"

gem 'jquery-rails'

gem 'rails_admin'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end
 
group :test do
  gem 'spork', '~> 0.9.2'
  gem 'guard-spork', '~> 1.1.0'
  gem 'guard-rspec', '~> 1.2.0'
  gem 'rb-fsevent'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'capybara'
  #gem 'capybara-webkit', '0.12.1'
  gem 'database_cleaner', '0.8'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.11.0'
  gem 'debugger'
end

group :development do
  gem 'thin'
  gem 'sinatra' #for ios tests
  gem 'capistrano'
  gem 'rvm-capistrano'
  gem 'capistrano-resque'
end
