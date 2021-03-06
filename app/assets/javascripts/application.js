//= require jquery2
//= require jquery_ujs
//= require jquery-ui
//= require popper
//= require bootstrap
//= require turbolinks
//= require_tree .

/* global $ */

$(window.document).on('turbolinks:load', function() {
  if (!window.autocomplete_source) {
    window.autocomplete_source = [];
  }
  if (!window.autocomplete_keywords) {
    window.autocomplete_keywords = [];
  }

  $(".long-text").shorten({ chars : 75 }).on('shorten::expand', function (e) {
    var $target = $(e.target);
    $target.find(".shorten-ellipses, .shorten-toggle").remove();
    $target.text($target.text());
  });
  
  $(".clickable-link").on("click", function(e) {
    window.location.href = $(e.target).closest("tr").attr("data-href");
  });
  $(".clickable-link a").on("click", function(e) {
    e.stopPropagation();
  });
  
  $(".a-button").on("click", function(e){
    e.preventDefault();
    e.stopPropagation();
    var $target = $(e.target).closest("a");
    var $form = $target.closest("form");
    $form.find('input[name="_method"]').val($target.attr("data-method"));
    $form.attr("action", $target.attr("data-action"));

    $form.submit();
  });

  $(".tag-keywords").tagit({
    fieldName: "keywords",
    tagSource: function(request, response) {
      var sources = window.autocomplete_source;
      var results = [];
      var term = request.term.toLowerCase();
      for (var index = 0; index < sources.length; index++) {
        if (results.length >= 100) break;
        if (sources[index].toLowerCase().indexOf(term) > -1) results.push(sources[index]);
      }
      response(results);
    },
    autocomplete: { 
      delay: 200, 
      minLength: 0
    },
    allowSpaces: true,
    caseSensitive: false,
    placeholderText: "Enter keywords(Name, Author, Category, License, or Description texts...)",
    onTagAdded: function(event, ui) {
      var description = "Description:";
      var text = ui.find(".tagit-label").text();
      var sources = window.autocomplete_source;
      var results = [];
      var term = text.toLowerCase();
      
      if (text.indexOf(description) === 0) {
        return;
      }
      
      for (var index = 0; index < sources.length; index++) {
        if (term === sources[index].toLowerCase()) {
          ui.find(".tagit-label").text(sources[index]);
          ui.find('input[type="hidden"]').val(sources[index]);
          return;
        }
      }
      
      ui.find(".tagit-label").text(description + text);
      ui.find('input[type="hidden"]').val(text);
    }
  });
  $(".filter-form").on("submit", function() {
    $(".tagit-choice").each(function(index, element) {
      var ui = $(element);
      ui.find('input[type="hidden"]').val(ui.find(".tagit-label").text());
    });
  });  
  
  $.each(window.autocomplete_keywords, function(index, keyword) {
    $(".tag-keywords").tagit("createTag", keyword);
    
    var tuple = keyword.split(":", 2);
    if (tuple.length === 2) {
      var selector = null;
      switch (tuple[0].toLowerCase()) {
        case "name":
          selector = ".table_cell_name";
          break;
        case "author":
          selector = ".table_cell_author";
          break;
        case "category":
          selector = ".table_cell_categories";
          break;
        case "license":
          selector = ".table_cell_license";
          break;
        case "description":
          selector = ".table_cell_description";
          break;
        default:
          break;
      }
      if (selector) {
        $(selector).mark(tuple[1], {
          separateWordSearch: false,
          diacritics: false
        });
      }
    }
  });
});
