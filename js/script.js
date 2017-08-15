//Search Function
function filterFunc(event) {
  var userInput = event.value.toUpperCase();
  $('.app').each(function() {
    if (this.textContent.toUpperCase().indexOf(userInput) > -1) {
      this.style.display = "";
    } else {
      this.style.display = "none";
    }
  });
}

//Load JSON file to generate app listing
$.getJSON("../connector_sdk/adapters/adapters.json", function (json) {
  var container = $("#container-apps");
  var listCol = 5;

  //Generate app list from adapters.JSON
  json.adapters.forEach(function (adapter) {
    var li = $('<li class="app">').appendTo(container);
    var a = $('<a target="_blank">').attr('href', adapter.link).appendTo(li);
    var img = $('<img>').attr('src', adapter.image).appendTo(a);
    $('<div class="item-name black-font"></div>').text(adapter.name).appendTo(li);
  });

  //Generate dummy box for responsive
  for (i = 0; i < (listCol); i++) {
    $('<li class="item flex-dummy"></li>').appendTo(container);
  }
});
