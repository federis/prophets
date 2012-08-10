Prophets::Application.routes.draw do
  
  resources :leagues

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "users#show"

end
