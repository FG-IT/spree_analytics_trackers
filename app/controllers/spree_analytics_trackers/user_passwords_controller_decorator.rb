module SpreeAnalyticsTrackers
  module UserPasswordsControllerDecorator
    def self.included(base)
      base.helper Spree::TrackersHelper
    end
  end
end


::Spree::UserPasswordsController.include(::SpreeAnalyticsTrackers::UserPasswordsControllerDecorator)

