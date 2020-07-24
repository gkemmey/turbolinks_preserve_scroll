require "application_system_test_case"

class PaginationAndScrollRestorationTest < ApplicationSystemTestCase
  def test_the_base_case_works
    go_to_inbox

    assert_equal 20, emails.count

    click_load_more
    assert_equal 40, emails.count

    click_load_more
    scroll_to_email(30)

    assert_scroll_restored do
      open_email(30)
      click_back_to_inbox
    end
  end

  def test_the_back_button_works
    go_to_inbox

    click_load_more
    click_load_more
    scroll_to_email(30)

    assert_scroll_restored do
      open_email(30)
      page.go_back
    end
  end

  def test_refreshing_starts_over
    go_to_inbox

    click_load_more
    click_load_more
    scroll_to_email(30)

    refresh_inbox

    assert_pagination_lost
    assert_scroll_lost unless using_safari?
  end

  def test_you_can_click_through_to_edit_click_back_on_that_page_and_still_recover
    go_to_inbox

    click_load_more
    click_load_more
    scroll_to_email(30)

    assert_scroll_restored do
      open_email(30)
      click_edit
      click_back_to_inbox
    end
  end

  def test_opening_an_email_in_a_new_tab_still_keeps_scroll_in_the_original_tab_and_loses_it_in_the_new_tab
    go_to_inbox

    click_load_more
    click_load_more
    scroll_to_email(30)

    original_tab = page.current_window
    new_tab = open_email_in_new_tab(30)

    assert_scroll_restored do
      within_window(original_tab) { open_email(30) }

      within_window(new_tab) do
        click_back_to_inbox

        assert_pagination_lost
        assert_scroll_lost
      end

      within_window(original_tab) { click_back_to_inbox }
    end
  end

  def test_you_can_have_two_inboxes_open_in_two_different_tabs_each_juggling_their_own_scroll_and_pagination
    go_to_inbox

    original_tab = page.current_window
    new_tab = go_to_inbox_in_new_tab

    within_window(original_tab) do
      click_load_more
      click_load_more
      scroll_to_email(30)
    end

    within_window(new_tab) do
      click_load_more
      click_load_more
      click_load_more
      scroll_to_email(50)
    end

    within_window(original_tab) do
      assert_scroll_restored do
        open_email(30)
        click_back_to_inbox
      end

      assert email(30, visible: true)
      assert 60, emails.count
    end

    within_window(new_tab) do
      assert_scroll_restored do
        open_email(50)
        click_back_to_inbox
      end

      assert email(50, visible: true)
      assert 80, emails.count
    end
  end

  private

    def go_to_inbox
      visit emails_path
      page.has_css?("h1", text: "Emails")
    end

    def go_to_inbox_in_new_tab
      tab_window = open_new_window(:tab)

      within_window(tab_window) do
        go_to_inbox
      end

      tab_window
    end

    def refresh_inbox
      page.refresh
      page.has_css?("h1", text: "Emails")
    end

    def click_load_more
      lenr = last_email_number_rendered
      find('button[type="submit"]', text: "Load More", visible: false).click

      page.has_content?("Subject ##{lenr + 1}") # forces test to wait for load to finish
    end

    def emails
      page.find_all("tbody > tr", visible: false)
    end

    def email(number, visible: false)
      page.find("tr", text: "Subject ##{number}", visible: visible)
    end

    def open_email(number)
      email(number).find("a", text: "Show", visible: false).click
    end

    def open_email_in_new_tab(number)
      link = email(number).find("a", text: "Show", visible: false)["href"]
      tab_window = open_new_window(:tab)

      within_window(tab_window) do
        visit(link)
        page.has_content?("Subject ##{number}")
      end

      tab_window
    end

    def click_back_to_inbox
      click_on "Back"
      page.has_css?("h1", text: "Emails")
    end

    def click_edit
      click_on "Edit"
      page.has_content?("Editing Email")
    end

    def last_email_number_rendered
      emails.last.text.scan(/#(\d+)/).first.first.to_i
    end

    def scroll_to_email(number)
      scroll_to page.find("td", text: "Subject ##{number}", visible: false), align: :top
    end

    def assert_scroll_restored
      document_scroll_top_before = execute_script("return document.documentElement.scrollTop")
      body_scroll_top_before = execute_script("return document.body.scrollTop")

      # it'd be hard to say you're testing for sure if they're both 0, so let's just fail it
      assert_not document_scroll_top_before == 0 && body_scroll_top_before == 0

      yield

      document_scroll_top_after = execute_script("return document.documentElement.scrollTop")
      body_scroll_top_after = execute_script("return document.body.scrollTop")

      assert document_scroll_top_before == document_scroll_top_after &&
               body_scroll_top_before == body_scroll_top_after,
             "Expected scroll before #{{ document: document_scroll_top_before, body: body_scroll_top_before }} " \
               "to equal scroll after #{{ document: document_scroll_top_after, body: body_scroll_top_after }}"
    end

    def assert_scroll_lost
      document_scroll_top = execute_script("return document.documentElement.scrollTop")
      body_scroll_top = execute_script("return document.body.scrollTop")

      assert document_scroll_top == 0 && body_scroll_top == 0
    end

    def assert_pagination_lost
      assert_equal 20, emails.count
    end

    def using_safari?
      self.class.driver.instance_variable_get(:@browser).name == :safari
    end
end
