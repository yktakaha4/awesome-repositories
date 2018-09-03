//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require popper
//= require bootstrap
//= require turbolinks
//= require_tree .

/* global $ */

$(function() {
  $(".show-popover").popover();
  
  $(".clickable-link").on("click", function(e) {
    window.location.href = $(e.target).closest("tr").attr("data-href");
  });
  $(".clickable-link a").on("click", function(e) {
    e.stopPropagation();
  });
  
  $(".autocomplete-keywords").autocomplete({
    source: ["hohohoho", "bakabon", "chou"]
  });
  
});
