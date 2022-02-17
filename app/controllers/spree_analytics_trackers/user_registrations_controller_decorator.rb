module SpreeAnalyticsTrackers
  module UserRegistrationsControllerDecorator
    def self.included(base)
      base.helper Spree::TrackersHelper
    end
  end
end


::Spree::UserRegistrationsController.include(::SpreeAnalyticsTrackers::UserRegistrationsControllerDecorator)

