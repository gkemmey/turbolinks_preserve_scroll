module Pagination
  extend ActiveSupport::Concern

  class Paginator
    attr_reader :controller, :collection, :items, :pagy
    delegate :request, :session, to: :controller

    def initialize(controller, collection)
      @controller = controller
      @collection = collection
      @items = []

      paginate
    end

    private

      def paginate
        load_just_the_next_page? ? single_page_of_items : all_previously_loaded_items
      end

      def load_just_the_next_page?
        # requires that however you "load more" -- infinite scroll, a button, whatever -- that
        # that request marks itself as an xhr request. remote forms do.
        request.xhr?
      end

      def single_page_of_items
        @pagy, @items = controller.send(:pagy, collection)
      end

      def all_previously_loaded_items
        1.upto(page_to_restore_to).each do |page|
          controller.send(:pagy, collection, page: page).then do |(pagy_object, results)|
            @pagy = pagy_object
            @items += results
          end
        end
      end

      def page_to_restore_to
        # it is just the page params, but guarded against being missing
        [controller.send(:pagy_get_vars, collection, {})[:page].try(:to_i), 1].compact.max
      end
  end

  def skipping_restoring_pagination?
    if request.full_page_refresh? && params[:page]
      redirect_to url_for(only_path: true)
      return true
    end

    false
  end

  def paginates(collection)
    Paginator.new(self, collection).then { |paginator| [paginator.pagy, paginator.items]}
  end
end
