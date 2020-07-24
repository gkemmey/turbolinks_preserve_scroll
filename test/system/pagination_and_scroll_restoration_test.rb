require "application_system_test_case"

class PaginationAndScrollRestorationTest < ApplicationSystemTestCase
  def test_the_base_case_works
    visit emails_path

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
    visit emails_path

    click_load_more
    click_load_more
    scroll_to_email(30)

    assert_scroll_restored do
      open_email(30)
      page.go_back
    end
  end

  def test_you_can_click_through_to_edit_click_back_on_that_page_and_still_recover
    visit emails_path

    click_load_more
    click_load_more
    scroll_to_email(30)

    assert_scroll_restored do
      open_email(30)
      click_edit
      click_back_to_inbox
    end
  end

  private

    def click_load_more
      lenr = last_email_number_rendered
      find('button[type="submit"]', text: "Load More", visible: false).click

      page.has_content?("Subject ##{lenr + 1}") # forces test to wait for load to finish
    end

    def emails
      page.find_all("tbody > tr", visible: false)
    end

    def email(number)
      page.find("tr", text: "Subject #30", visible: false)
    end

    def open_email(number)
      email(number).find("a", text: "Show", visible: false).click
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
end
