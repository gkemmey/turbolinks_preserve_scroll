on(document, "click", "a[data-restore-pagination]", function(event) {
  const { target: a } = event
  const { restorePagination: key } = a.dataset
  const lastPage = sessionStorage.getItem(key)

  if (lastPage) {
    a.href = lastPage
  }
})
