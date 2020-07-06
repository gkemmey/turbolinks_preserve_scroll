// https://developer.mozilla.org/en-US/docs/Web/API/Element/matches
if (!Element.prototype.matches) {
  Element.prototype.matches =
    Element.prototype.msMatchesSelector ||
    Element.prototype.webkitMatchesSelector;
}

// https://developer.mozilla.org/en-US/docs/Web/API/Element/closest
if (!Element.prototype.closest) {
  Element.prototype.closest = function(s) {
    var el = this;
    if (!document.documentElement.contains(el)) return null;
    do {
      if (el.matches(s)) return el;
      el = el.parentElement || el.parentNode;
    } while (el !== null && el.nodeType === 1);
    return null;
  };
}

function on(element, event, selector, handler) {
  element.addEventListener(event, function(_event) {
    var target = _event.target;

    while (target && target !== this) {
      if (target.matches(selector)) {
          handler.call(target, _event);
      }

      target = target.parentNode;
    }
  });
}
