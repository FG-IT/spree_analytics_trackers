module SpreeAnalyticsTrackers
  module UserSessionsControllerDecorator
    def self.included(base)
      base.helper 'spree/trackers'
    end
  end
end


::Spree::UserSessionsController.include SpreeAnalyticsTrackers::UserSessionsControllerDecorator

