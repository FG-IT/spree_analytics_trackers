module SpreeAnalyticsTrackers
  module UserConfirmationsControllerDecorator
    def self.included(base)
      base.helper 'spree/trackers'
    end
  end
end


::Spree::UserConfirmationsController.include(::SpreeAnalyticsTrackers::UserConfirmationsControllerDecorator)

