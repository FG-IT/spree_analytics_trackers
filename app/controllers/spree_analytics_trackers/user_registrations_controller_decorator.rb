module SpreeAnalyticsTrackers
  module UserRegistrationsControllerDecorator
    def self.included(base)
      base.helper 'spree/trackers'
    end
  end
end


::Spree::UserRegistrationsController.include(::SpreeAnalyticsTrackers::UserRegistrationsControllerDecorator)

