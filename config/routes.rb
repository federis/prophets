Prophets::Application.routes.draw do
  
  resources :memberships, :only => :index

  resources :leagues do
    resources :memberships, :except => :index
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

  devise_for :users, :controllers => { :registrations => "registrations",
                                       :omniauth_callbacks => "omniauth_callbacks" }

  resources :tokens, :only => :create do
    collection do
      post "facebook"
    end
  end
  
  root :to => "leagues#index"

end
