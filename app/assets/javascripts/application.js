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
  
  $(".tag-keywords").tagit({
    fieldName: "keywords",
    tagSource: function(request, response) {
      response(["Name:AFNetworking", "License:Apache License 2.0", "Author:Alamofire"]);
    },
    autocomplete: { 
      delay: 200, 
      minLength: 0
    },
    showAutocompleteOnFocus: true,
    allowSpaces: true,
    placeholderText: "Enter keywords(Name, Author, Category, License, or Description texts...)"
  });
  
});
