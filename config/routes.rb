Prophets::Application.routes.draw do
  resources :answers

  resources :leagues do
    resources :memberships
    resources :questions
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "leagues#index"

end
