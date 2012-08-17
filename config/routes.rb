Prophets::Application.routes.draw do
  
  resources :questions

  resources :leagues do
    resources :memberships
  end

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "leagues#index"

end
