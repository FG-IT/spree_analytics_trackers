Deface::Override.new(
    virtual_path: 'spree/products/show',
    name: 'add_product_viewed_to_products_show',
    insert_bottom: '[data-hook="product_show"]',
    partial: 'spree/shared/trackers/segment/product_viewed.js',
    :original => 'a34bc2cc550e15c59a19a85a9ff4c7f1b9713695'
)

Deface::Override.new(
    virtual_path: 'spree/products/show',
    name: 'add_ga_product_viewed_to_products_show',
    insert_bottom: '[data-hook="product_show"]',
    partial: 'spree/shared/trackers/google_analytics/product_viewed.js',
    :original => 'a890bf88c4a70f5b283d74003d3921254e34ff5d'
)

