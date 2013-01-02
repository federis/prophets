Prophets::Application.routes.draw do
  
  resources :memberships, :only => :index

  resources :tags, :only => :index do
    resources :leagues
  end

  resources :leagues do
    resources :memberships, :except => :index
    resources :questions do
      put "approve", :on => :member
    end

    resources :bets, :only => :index

    resources :comments

    resources :leaderboards, :only => :index
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

  devise_for :users, :controllers => { :registrations => "registrations",
                                       :omniauth_callbacks => "omniauth_callbacks" }

  resources :tokens, :only => :create do
    collection do
      post "facebook"
    end
  end
  
  root :to => "leagues#index"

end
