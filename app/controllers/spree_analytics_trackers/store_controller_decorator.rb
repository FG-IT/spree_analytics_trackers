module SpreeAnalyticsTrackers
  module StoreControllerDecorator
    def self.included(base)
      base.include ::Spree::BaseHelper
      base.helper 'spree/trackers'
    end
  end
end


::Spree::StoreController.include(::SpreeAnalyticsTrackers::StoreControllerDecorator)

