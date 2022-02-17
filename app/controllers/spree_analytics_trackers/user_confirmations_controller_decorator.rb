module SpreeAnalyticsTrackers
  module UserConfirmationsControllerDecorator
    def self.included(base)
      base.helper Spree::TrackersHelper
    end
  end
end


::Spree::UserConfirmationsController.include(::SpreeAnalyticsTrackers::UserConfirmationsControllerDecorator)

