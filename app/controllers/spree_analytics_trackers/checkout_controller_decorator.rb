module SpreeAnalyticsTrackers
  module CheckoutControllerDecorator
    def self.included(base)
      base.helper 'spree/trackers'
    end
  end
end


::Spree::CheckoutController.include(::SpreeAnalyticsTrackers::CheckoutControllerDecorator)

