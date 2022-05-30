if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/shared/_head',
    name: 'add_matomo_initializer_to_spree_application',
    insert_after: 'title',
    partial: 'spree/shared/trackers/matomo/initializer.js',
  )
end
