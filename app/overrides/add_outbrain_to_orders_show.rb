if Gem.loaded_specs['spree_core'].version >= Gem::Version.create('3.5.0')
  Deface::Override.new(
    virtual_path: 'spree/orders/show',
    name: 'add_outbrain_purchase_to_orders_show',
    insert_before: "#order_summary",
    partial: 'spree/shared/trackers/outbrain/purchase.js',
  )
end
