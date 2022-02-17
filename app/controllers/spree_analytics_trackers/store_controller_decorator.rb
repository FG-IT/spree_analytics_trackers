module SpreeAnalyticsTrackers
  module StoreControllerDecorator
    def self.included(base)
      base.include ::Spree::BaseHelper
      base.include Spree::TrackersHelper
    end
  end
end


::Spree::StoreController.include(::SpreeAnalyticsTrackers::StoreControllerDecorator)

