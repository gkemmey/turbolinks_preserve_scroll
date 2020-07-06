module Pagination
  extend ActiveSupport::Concern

  class Paginator
    attr_reader :controller, :collection, :items, :pagy, :with_previously_loaded
    delegate :request, :session, to: :controller

    def initialize(controller, collection, with_previously_loaded: false)
      @controller = controller
      @collection = collection
      @with_previously_loaded = with_previously_loaded
      @items = []

      paginate
    end

    private

      def paginate
        if request.full_page_refresh?
          clear_session_cache
          single_page_of_items

        elsif async_load_just_the_next_page?
          single_page_of_items

        else
          all_previously_loaded_items
        end
      end

      def async_load_just_the_next_page?
        # requires that however you "load more" -- inifinite scroll, a button, whatever -- that
        # that request marks itself as an xhr request. remote forms do.
        request.xhr?
      end

      def cache_key
        "#{controller.controller_name}_#{controller.action_name}"
      end

      def clear_session_cache
        if (caches = session[:pagination])
          caches.delete(cache_key)
        end
      end

      def session_cache
        if (caches = session[:pagination])
          caches[cache_key]
        end
      end

      def write_to_session_cache(page)
        session[:pagination] ||= {}
        session[:pagination][cache_key] = page
      end

      def max_page_loaded
        [controller.send(:pagy_get_vars, collection, {})[:page].try(:to_i), session_cache, 1].compact.max
      end

      def single_page_of_items
        @pagy, @items = controller.send(:pagy, collection).tap { write_to_session_cache(max_page_loaded) }
      end

      def all_previously_loaded_items
        1.upto(max_page_loaded).each do |page|
          controller.send(:pagy, collection, page: page).then do |(pagy_object, results)|
            @pagy = pagy_object
            @items += results
          end
        end
      end
  end

  included do
    before_action { session.delete(:pagination) if request.full_page_refresh? }
  end

  def paginates(collection, options = {})
    Paginator.new(self, collection, **options).then { |paginator| [paginator.pagy, paginator.items]}
  end
end
