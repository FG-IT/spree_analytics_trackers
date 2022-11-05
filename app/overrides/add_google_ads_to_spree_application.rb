if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_google_ads_initializer_to_spree_application',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/google_ads/initializer.js',
    original: 'cfa30a2831d9a41394c03229cd28b3c7eee69585'
  )
end
