module InspectRequest
  refine ActionDispatch::Request do
    def turbolinks?
      !get_header("HTTP_TURBOLINKS_REFERRER").nil?
    end

    def full_page_refresh?
      !xhr? && !turbolinks?
    end
  end
end
