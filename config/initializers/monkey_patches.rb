module ActionDispatch
  class Request
    def full_page_refresh?
      get_header("HTTP_CACHE_CONTROL") == "max-age=0" ||
        (
          user_agent.include?("Safari") &&
          get_header("HTTP_TURBOLINKS_REFERRER").nil? &&
          (referrer.nil? || referrer == url)
        )
    end
  end
end
