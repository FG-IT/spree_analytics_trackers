Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resources :trackers

    get '/matomo-order-analytics', to: 'matomo_analytics#order_analytics', as: :matomo_order_analytics
  end
end
