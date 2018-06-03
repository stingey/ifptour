Rails.application.routes.draw do

  get 'photos/index'

  get 'doubles/index'

  get 'singles/index'

  get 'pro_shop/show'

  devise_for :users
  root to: 'landing#index'
  resources :landing, only: %i[index]
  resources :tournaments, only: %i[index show]
  resources :results, only: %i[index show]
  resources :admins

  namespace :rankings do
    resource :ranks, only: %i[create]
    resources :singles, only: %i[index]
    resources :doubles, only: %i[index]
    resources :womens_singles, only: %i[index]
    resources :womens_doubles, only: %i[index]
  end

  resources :photos, only: %i[index show create new destroy]
  resources :hall_of_fames, only: %i[index]
  resources :rules, only: %i[index]
  resources :clubs, only: %i[index]
  resource :pro_shop, only: %i[show]

  resources :players, only: %i[index new create show edit update]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
