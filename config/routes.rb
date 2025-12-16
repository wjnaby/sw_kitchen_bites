require "sidekiq/web"

Rails.application.routes.draw do
  # -------------------- Sidekiq --------------------
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  # -------------------- Admin --------------------
  namespace :admin do
    root to: "dashboard#index"
    get "dashboard", to: "dashboard#index", as: :dashboard

    # User management
    get "all_users", to: "dashboard#all_users", as: :all_users
    patch "users/:id/toggle_active", to: "dashboard#toggle_user_active", as: :toggle_user_active
    delete "users/:id", to: "dashboard#destroy_user", as: :destroy_user

    # Recipe management
    get "all_recipes", to: "dashboard#all_recipes", as: :all_recipes
    get "reported_recipes", to: "dashboard#reported_recipes", as: :reported_recipes
    delete "recipes/:id", to: "dashboard#destroy_recipe", as: :destroy_recipe
    get "recipes/:id/view", to: "dashboard#view_recipe", as: :view_recipe
  end

  # -------------------- Frontend --------------------
  root "feeds#index"
  get "feed", to: "feeds#index"
  get "search", to: "search#index"

  # -------------------- Devise --------------------
  devise_for :users

  # -------------------- Users --------------------
  resources :users, param: :username, only: [:show, :edit, :update] do
    member do
      post :follow
      delete :unfollow
    end
  end

  # -------------------- Recipes --------------------
  resources :recipes do
    member do
      delete :delete_image
    end
    resources :comments, only: [:create, :destroy]
    resource :like, only: [:create, :destroy]
    resource :bookmark, only: [:create, :destroy]
  end

  # -------------------- Bookmarks & Notifications --------------------
  resources :bookmarks, only: [:index]
  resources :notifications, only: [:index, :show]
end