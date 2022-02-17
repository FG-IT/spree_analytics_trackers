module SpreeAnalyticsTrackers
  module CheckoutControllerDecorator
    def self.included(base)
      base.helper Spree::TrackersHelper
    end
  end
end


::Spree::CheckoutController.include(::SpreeAnalyticsTrackers::CheckoutControllerDecorator)

