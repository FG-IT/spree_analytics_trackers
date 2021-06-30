module Spree::ProductsControllerDecorator

  def self.prepended(base)
    base.helper Spree::TrackersHelper
  end

end

Spree::ProductsController.prepend Spree::ProductsControllerDecorator