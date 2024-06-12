module SpreeAnalyticsTrackers
  module ProductsControllerDecorator
    def self.included(base)
      base.helper 'spree/trackers'
    end
  end
end


::Spree::ProductsController.include(::SpreeAnalyticsTrackers::ProductsControllerDecorator)

