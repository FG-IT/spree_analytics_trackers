spree_version = Gem.loaded_specs['spree_core'].version
unless spree_version >= Gem::Version.create('3.4.0') && spree_version < Gem::Version.create('3.5.0')
  Deface::Override.new(
    virtual_path: 'spree/checkout/edit',
    name: 'add_order_to_checkout_edit',
    insert_after: '[data-hook="checkout_content"]',
    partial: 'spree/shared/order.js',
  )
end
