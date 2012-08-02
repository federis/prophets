source 'https://rubygems.org'

gem 'rails', '3.2.7'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'unicorn'

gem 'devise', '~> 2.1'
gem 'omniauth-facebook'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

 
group :test do
  gem 'spork', '~> 0.9.2'
  gem 'guard-spork', '~> 1.1.0'
  gem 'guard-rspec', '~> 1.2.0'
  gem 'factory_girl_rails', '~> 3.5.0'
  gem 'rb-fsevent'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.11.0'
  gem 'debugger'
  gem 'mysql2'
end

group :production do
  gem 'pg'
end
