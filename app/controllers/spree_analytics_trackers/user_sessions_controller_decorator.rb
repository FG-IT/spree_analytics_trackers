module SpreeAnalyticsTrackers
  module UserSessionsControllerDecorator
    def self.included(base)
      base.helper Spree::TrackersHelper
    end
  end
end


::Spree::UserSessionsController.include SpreeAnalyticsTrackers::UserSessionsControllerDecorator

