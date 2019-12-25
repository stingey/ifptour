# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }
  root to: 'clubs#index'
  resources :landing, only: %i[index]
  resources :tournaments, only: %i[index show]
  resources :results, only: %i[index show]
  resources :admins

  namespace :rankings do
    resource :ranks, only: %i[create] do
      post '/collect-points-job', to: 'ranks#collect_points_job'
      post '/create-players-with-points-job', to: 'ranks#create_players_with_points_job'
    end
    resources :singles, only: %i[index]
    resources :doubles, only: %i[index]
    resources :womens_singles, only: %i[index]
    resources :womens_doubles, only: %i[index]
  end

  # resources :local_tournaments, only: %i[index new]
  resources :photos, only: %i[index show create new destroy]
  resources :hall_of_fames, only: %i[index]
  resources :rules, only: %i[index]
  resources :local_tournaments, only: :index
  resources :clubs, only: %i[index new show create] do
    resources :local_tournaments, only: %i[new show edit create destroy] do
      resources :participants, only: %i[create destroy]
      get '/generate-tournament', to: 'local_tournaments#generate_tournament', as: :generate_tournament
      post '/enter-match-result/:match_id', to: 'local_tournaments#enter_match_result', as: :enter_match_result
      post '/finalize', to: 'local_tournaments#finalize', as: :finalize
    end
  end
  resource :pro_shop, only: %i[show]

  resources :players, only: %i[index new create show edit update]

  get '/404',       to: 'errors#not_found',             as: :not_found
  get '/500',       to: 'errors#internal_server_error', as: :internal_server_error
  get '/422',       to: 'errors#unprocessable_entity',  as: :unprocessable_entity
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
# rubocop:enable Metrics/BlockLength
