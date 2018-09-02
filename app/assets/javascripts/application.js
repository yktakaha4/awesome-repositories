//= require jquery
//= require jquery_ujs
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
});
