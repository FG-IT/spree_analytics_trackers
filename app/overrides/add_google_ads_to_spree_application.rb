if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_google_ads_initializer_to_spree_application',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/google_ads/initializer.js'
  )
end
