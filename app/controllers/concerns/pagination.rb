module Pagination
  extend ActiveSupport::Concern

  class Paginator
    attr_reader :controller, :collection, :items, :pagy
    delegate :request, to: :controller

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
        [controller.send(:pagy_get_vars, collection, {})[:page].try(:to_i), 1].compact.max
      end
  end

  def clear_session_storage_when_fresh_unpaginated_listing_loaded
    script = <<~JS
      sessionStorage.removeItem('#{last_page_fetched_key}');
    JS

    helpers.content_tag(:script, script.html_safe, type: "text/javascript",
                                                   data: { turbolinks_eval: "false" })
  end

  def current_page_path
    request.fullpath
  end

  def fresh_unpaginated_listing
    url_for(only_path: true)
  end

  def last_page_fetched_key
    "#{controller_name}_index"
  end

  def paginates(collection)
    Paginator.new(self, collection).then { |paginator| [paginator.pagy, paginator.items] }
  end

  def redirecting_to_fresh_unpaginated_listing?
    if request.full_page_refresh? && params[:page]
      redirect_to fresh_unpaginated_listing
      return true
    end

    false
  end

  included do
    helper_method :clear_session_storage_when_fresh_unpaginated_listing_loaded,
                  :current_page_path,
                  :last_page_fetched_key
  end
end
