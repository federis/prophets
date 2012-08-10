Prophets::Application.routes.draw do
  
  resources :leagues, :only => :create

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :tokens, :only => :create
  
  root :to => "users#show"

end
