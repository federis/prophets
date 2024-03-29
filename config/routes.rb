require 'resque/server'

Prophets::Application.routes.draw do
  resources :memberships, :only => :index

  resources :tags, :only => :index do
    resources :leagues
  end

  resources :leagues do
    resources :memberships
    resources :questions do
      put "approve", :on => :member
    end

    resources :bets, :only => :index
    resources :comments
    resources :activities, only: :index

    get "leaderboard" => "leaderboard#index", as: "leaderboard"
  end

  resources :questions, :only => [] do
    resources :answers do
      put "judge", :on => :member
    end

    resources :comments
  end

  resources :answers, :only => [] do
    resources :bets
  end

  resources :bets, :only => [:show] do
    resources :comments
  end

  devise_for :users, :controllers => { :registrations => "registrations",
                                       :omniauth_callbacks => "omniauth_callbacks" }

  resources :users, :only => :show do
    collection do
      post "facebook"
    end
  end

  resources :device_tokens, :only => :create 
  delete "device_tokens" => "device_tokens#destroy"
  resources :tokens, :only => :create do
    collection do
      post "facebook"
    end
  end
  
  root :to => "home#index"

  # Super-user only routes
  constraints lambda{|request| request.env['warden'].user.try(:superuser) == 1 } do
    mount RailsAdmin::Engine => '/moses', :as => 'rails_admin'
    mount Resque::Server, :at => "/resque"
  end

end
