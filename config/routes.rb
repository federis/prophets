Prophets::Application.routes.draw do
  
  resources :league_memberships

  resources :leagues

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "users#show"

end
