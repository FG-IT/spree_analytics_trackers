if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/shared/_head',
    name: 'add_facebook_pixel_to_spree_application',
    insert_after: 'title',
    partial: 'spree/shared/trackers/facebook_pixel/initializer.js',
  )
end
