Deface::Override.new(
  virtual_path: 'spree/admin/dashboard/index',
  name: 'show_order_source_charts',
  insert_after: '#adminDashboard',
  partial: 'spree/admin/dashboard/matomo/order_analytics'
)
