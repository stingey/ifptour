Rails.application.routes.draw do

  get 'doubles/index'

  get 'singles/index'

  get 'pro_shop/show'

  devise_for :users
  root to: 'landing#index'
  resources :landing, only: %i(index)
  resources :tournaments, only: %i(index show)
  resources :results, only: %i(index show)
  resource :rankings, only: %i(index show) do
    resources :singles, only: %i(index)
    get '/womens_singles/' => 'singles#womens_singles'
    resources :doubles, only: %i(index)
    get '/womens_doubles/' => 'doubles#womens_doubles'
  end
  resources :photos, only: %i(index show)
  resources :hall_of_fames, only: %i(index)
  resources :rules, only: %i(index)
  resources :clubs, only: %i(index)

  resource :pro_shop, only: %i(show)

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
