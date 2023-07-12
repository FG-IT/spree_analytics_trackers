if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/static_page',
    name: 'add_klaviyo_initializer_to_static_page',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/klaviyo/initializer.js'
  )
end