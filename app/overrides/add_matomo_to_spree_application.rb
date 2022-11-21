if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_matomo_initializer_to_spree_application',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/matomo/initializer.js',
  )

  Deface::Override.new(
    virtual_path: 'spree/layouts/checkout',
    name: 'add_matomo_initializer_to_checkout',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/matomo/initializer.js',
  )
end
