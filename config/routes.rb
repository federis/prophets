Prophets::Application.routes.draw do
  resources :bets

  resources :leagues do
    resources :memberships
    resources :questions do
      put "approve", :on => :member
    end
  end

  resources :questions, :only => nil do
    resources :answers do
      put "judge", :on => :member
    end
  end

  resources :answers, :only => nil do
    resources :bets
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "leagues#index"

end
