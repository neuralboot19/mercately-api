class ErrorsController < ApplicationController
  include CurrentRetailer

  def not_found
    respond_to do |format|
      if current_retailer
        format.html { render template: 'errors/not_found', layout: 'dashboard', status: 404 }
      else
        format.html { render template: 'errors/not_found', layout: 'layouts/application', status: 404 }
      end
    end
  end

  def internal_error
  end
end
