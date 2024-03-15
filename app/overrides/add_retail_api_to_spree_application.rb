Deface::Override.new(
  virtual_path: 'spree/layouts/spree_application',
  name: 'add_retail_api_tracker_to_spree_application',
  insert_bottom: 'body',
  partial: 'spree/shared/trackers/retail_api/common.js'
)

Deface::Override.new(
  virtual_path: 'spree/orders/show',
  name: 'add_retail_api_tracker_to_orders_show',
  insert_before: "#order_summary",
  partial: 'spree/shared/trackers/retail_api/common.js'
)