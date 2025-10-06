# config/routes.rb
Rails.application.routes.draw do
  namespace :admin do
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index", as: :dashboard

    resources :users, only: [:index, :show, :edit, :update, :destroy]
    resources :recipes, only: [:index, :show, :edit, :update, :destroy]
    resources :active_users, only: [:index, :show, :edit, :update, :destroy]
    resources :popular_recipes, only: [:index, :show, :edit, :update, :destroy]
    resources :reported_recipes, only: [:index, :show, :edit, :update, :destroy]
  end

  root "feeds#index"
  get "feed", to: "feeds#index"

  get "search", to: "search#index"

  devise_for :users

  resources :users, param: :username, only: [:show, :edit, :update] do
    member do
      post :follow
      delete :unfollow
    end
  end

  resources :recipes do
    resources :comments, only: [:create, :destroy]
    resource :like, only: [:create, :destroy]
    resource :bookmark, only: [:create, :destroy]
  end

  resources :bookmarks, only: [:index]

  # ✅ Notifications without mark_as_read
  resources :notifications, only: [:index, :show]
end
