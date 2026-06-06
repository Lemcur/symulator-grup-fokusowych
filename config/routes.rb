require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users

  authenticate :user do
    mount Sidekiq::Web => "/sidekiq"
  end

  resources :products do
    resources :images, only: :destroy, controller: "product_images"
  end
  resources :focus_groups do
    member do
      get :status
      post :approve
    end
    resources :personas, only: [:new, :create, :edit, :update, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root to: "focus_groups#index", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")
end
