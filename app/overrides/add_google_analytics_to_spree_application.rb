if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_google_analytics_initializer_to_spree_application',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/google_analytics/initializer.js'
  )

  Deface::Override.new(
    virtual_path: 'spree/layouts/checkout',
    name: 'add_google_analytics_initializer_to_checkout',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/google_analytics/initializer.js'
  )
end
