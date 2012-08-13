
var copy = function(objA, objB) {
	for (var i in objB) {
		if (objB.hasOwnProperty(i) && objB[i] !== null) {
			objA[i] = objB[i];
		}
	};
};

var httpRequest = function(config) {
	var defConfig = {
		url: 'data_layer.php',
		dataType: 'jsonp',
		type: "GET",
		jsonp: 'jsonp',
		timeout: 5000,
		error: function() {
			alert("ERROR!!");
		}
	};
	copy(defConfig, config);
	$.ajax(defConfig);
};

var WCLogin = new function() {
	
	var _usernameObj;
	var _passwordObj;
	var _this = this;
	
	var submitByKey = function(event) {
		event = window.event || event;
		if (event.keyCode == 13) {
			_this.submit();
		}
	};

	this.submit = function() {
		var username = _usernameObj.value;
		var password = _passwordObj.value;
		httpRequest({
			url: "authentication.php",
			data: {
				username: username,
				password: password
			},
			success: function(result, status) {
				if (result == "success") {
					location.href = "index.php";
				}
				else {
					//_passwordObj.className += " wrong-password";
					_passwordObj.value = "";
				}
			}
		});
	};
	
	this.setInputIds = function(usernameId, passwordId) {
		_usernameObj = document.getElementById(usernameId);
		_passwordObj = document.getElementById(passwordId);
		_usernameObj.onkeyup = submitByKey;
		_passwordObj.onkeyup = submitByKey;
		_usernameObj.focus();
	};
};

$(document).ready(function() {
	WCLogin.setInputIds("username", "password");
});
