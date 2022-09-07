spree_version = Gem.loaded_specs['spree_core'].version
unless spree_version >= Gem::Version.create('3.4.0') && spree_version < Gem::Version.create('3.5.0')
  Deface::Override.new(
    virtual_path: 'spree/products/index',
    name: 'add_products_searched_to_products_list_matomo',
    insert_before: '[data-hook="search_results"]',
    partial: 'spree/shared/trackers/matomo/products_searched.js',
  )
end
