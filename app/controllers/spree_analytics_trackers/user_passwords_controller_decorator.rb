module SpreeAnalyticsTrackers
  module UserPasswordsControllerDecorator
    def self.included(base)
      base.helper 'spree/trackers'
    end
  end
end


::Spree::UserPasswordsController.include(::SpreeAnalyticsTrackers::UserPasswordsControllerDecorator)

