spree_version = Gem.loaded_specs['spree_core'].version
unless spree_version >= Gem::Version.create('3.3.0') && spree_version < Gem::Version.create('3.5.0') && spree_version != Gem::Version.create('3.5.0.alpha')
  Deface::Override.new(
    virtual_path: 'spree/layouts/spree_application',
    name: 'add_outbrain_page_viewed_to_spree_application',
    insert_top: 'body',
    partial: 'spree/shared/trackers/outbrain/page_viewed.js',
  )
end
