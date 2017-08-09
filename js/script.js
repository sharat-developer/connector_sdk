//Search Function
function filterFunc() {
	var input, filter, obj;
	input = document.getElementById('search-form');
	filter = input.value.toUpperCase();
	obj = document.getElementsByClassName('filter');

	for (i = 0; i < obj.length; i++) {
		if (obj[i].lastChild.innerHTML.toUpperCase().indexOf(filter) > -1) {
			obj[i].style.display = "";
		} else {
			obj[i].style.display = "none";
		}
	}
}

//Generate App list from Json file
$.getJSON("../connector_sdk/js/adapters.json", function (json) {
	var container = document.getElementById("container-apps");
    var listCol = 5;
	for (var i = 0; i < json.adapters.length; i++) {
		var obj = json.adapters[i];
		var div = document.createElement('div');
        var img = document.createElement('img');
        var a = document.createElement('a');
		div.className = 'filter';	
		img.src = obj.image;	
		a.href = obj.link;
		a.appendChild(img);
		a.target = '_blank';
		div.appendChild(a);
		div.innerHTML += "<div class='item-name black-font'>" + obj.name + "</div>";
		container.appendChild(div);
	}
    
    //Generate dummy box for responsive
    for (i = 0; i < (listCol); i++) {
        var div = document.createElement('div');
        div.className = 'item flex-dummy';
        container.appendChild(div);
    }
});
