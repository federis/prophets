Prophets::Application.routes.draw do
  resources :leagues do
    resources :memberships
    resources :questions
  end

  resources :questions, :only => nil do
    resources :answers
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "leagues#index"

end
