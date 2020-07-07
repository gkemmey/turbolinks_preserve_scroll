// adapted from examples here:
//
//   https://github.com/turbolinks/turbolinks/issues/2#issuecomment-180631563
//   https://stackoverflow.com/a/41704079/1947079
//
Turbolinks.savedScrolls = {}

document.addEventListener("turbolinks:render", function(event) {
  const savedScroll = Turbolinks.savedScrolls[window.location.href]
  if (!savedScroll) { return; }

  delete(Turbolinks.savedScrolls[window.location.href])

  if (savedScroll.document != null) { /* single `=` that catches undefined, too */
    if (savedScroll.document < document.documentElement.scrollHeight) {
      document.documentElement.scrollTop = savedScroll.document
    }
  }

  if (savedScroll.document != null) {
    if (savedScroll.body < document.body.scrollHeight) {
      document.body.scrollTop = savedScroll.body
    }
  }
});

document.addEventListener("turbolinks:before-visit", function(event) {
  if (document.querySelector("body[data-preserve-scroll=true]")) {
    Turbolinks.savedScrolls = {
      [window.location.href]: {
        document: document.documentElement.scrollTop,
        body: document.body.scrollTop
      }
    }
  }
});
