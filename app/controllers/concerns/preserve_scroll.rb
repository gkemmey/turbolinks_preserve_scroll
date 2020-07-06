module PreserveScroll
  extend ActiveSupport::Concern

  included do
    helper_method :maybe_preserve_scroll
  end

  def maybe_preserve_scroll
    @preserve_scroll ? 'data-preserve-scroll=true' : ''
  end

  def preserve_scroll
    @preserve_scroll = true
  end
end
