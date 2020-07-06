class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pagination
  include PreserveScroll
end
