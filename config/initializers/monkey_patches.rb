module ActionDispatch
  class Request
    def full_page_refresh?
      get_header("HTTP_CACHE_CONTROL") == "max-age=0"
    end
  end
end
