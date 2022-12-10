Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resources :trackers

    get '/matomo-order-analytics', to: 'matomo_analytics#order_analytics', as: :matomo_order_analytics
    get '/matomo-analytics', to: 'matomo_analytics#index', as: :matomo_analytics
    get '/matomo-sales-performance', to: 'matomo_analytics#sales_performance'
    get '/matomo-visits-by-source', to: 'matomo_analytics#visits_by_source'
    get '/matomo-visits-by-social', to: 'matomo_analytics#visits_by_social'
    get '/matomo-visits-by-device', to: 'matomo_analytics#visits_by_device'
    get '/matomo-visits-by-websites', to: 'matomo_analytics#visits_by_websites'
    get '/matomo-visits-by-countries', to: 'matomo_analytics#visits_by_countries'
    get '/matomo-visits-by-regions', to: 'matomo_analytics#visits_by_regions'
    get '/matomo-visits-summary', to: 'matomo_analytics#visits_summary'
  end
end
