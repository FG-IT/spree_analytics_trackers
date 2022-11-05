if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_em_initializer_to_spree_application',
    insert_bottom: 'body',
    partial: 'spree/shared/trackers/em/initializer.js'
  )
end
