on(document, "click", "a[data-restores-last-page-fetched]", function(event) {
  const { target: a } = event
  const { restoresLastPageFetched: key } = a.dataset
  const lastPageFetched = sessionStorage.getItem(key)

  if (lastPageFetched) {
    a.href = lastPageFetched
  }
})
