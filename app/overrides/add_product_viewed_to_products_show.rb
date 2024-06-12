Deface::Override.new(
    virtual_path: 'spree/products/show',
    name: 'add_product_viewed_to_products_show',
    insert_bottom: '[data-hook="product_show"]',
    partial: 'spree/shared/trackers/segment/product_viewed.js'
)

Deface::Override.new(
    virtual_path: 'spree/products/show',
    name: 'add_ga_product_viewed_to_products_show',
    insert_bottom: '[data-hook="product_show"]',
    partial: 'spree/shared/trackers/google_analytics/product_viewed.js'
)

