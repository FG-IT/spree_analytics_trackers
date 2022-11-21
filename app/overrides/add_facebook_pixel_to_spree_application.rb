if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_facebook_pixel_initializer_to_spree_application',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/facebook_pixel/initializer.js'
  )

  Deface::Override.new(
    virtual_path: 'spree/layouts/checkout',
    name: 'add_facebook_pixel_initializer_to_checkout',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/facebook_pixel/initializer.js'
  )
end
