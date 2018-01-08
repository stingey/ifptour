Rails.application.routes.draw do
  get 'clubs/index'

  get 'hall_of_fames/index'

  get 'rules/index'

  get 'photos/index'

  get 'photos/show'

  get 'pro_shop/show'

  get 'rankings/index'

  get 'rankings/show'

  get 'results/index'

  get 'results/show'

  get 'tournaments/index'

  get 'tournaments/show'

  devise_for :users
  root to: 'landing#index'
  resources :landing, only: %i(index)
  resources :tournaments, only: %i(index show)
  resources :results, only: %i(index show)
  resources :rankings, only: %i(index show)
  resources :photos, only: %i(index show)
  resources :hall_of_fames, only: %i(index)
  resources :rules, only: %i(index)
  resources :clubs, only: %i(index)

  resource :pro_shop, only: %i(show)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
