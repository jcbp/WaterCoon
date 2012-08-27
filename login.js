
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
	
	var _this = this;
	var _login = {
		username: "",
		password: ""
	};
	var _signup = {
		username: "",
		email: "",
		password: "",
		checkbox: null
	};
	
	var submitLoginByKey = function(event) {
		event = window.event || event;
		if (event.keyCode == 13) {
			_this.submit();
		}
	};

	var submitSignupByKey = function(event) {
		event = window.event || event;
		if (event.keyCode == 13) {
			_this.submitSignup();
		}
	};

	this.submit = function() {
		var username = _login.username.value;
		var password = _login.password.value;
		httpRequest({
			url: "Auth.php",
			data: {
				username: username,
				password: password
			},
			success: function(result, status) {
				if (result == "success") {
					location.href = "index.php";
				}
				else {
					//_login.password.className += " wrong-password";
					_login.password.value = "";
				}
			}
		});
	};

	this.submitSignup = function() {
		if (_signup.checkbox.checked) {
			var username = _signup.username.value;
			var email = _signup.email.value;
			var password = _signup.password.value;

			httpRequest({
				url: "SignUp.php",
				data: {
					username: username,
					email: email,
					password: password
				},
				success: function(result, status) {
					if (result == "success") {
						_signup.username.value = "";
						_signup.email.value = "";
						_signup.password.value = "";
						alert("Welcome! The registration was successful.");
					}
					else {
						alert("algo anda mal");
					}
				}
			});
		}
		else {
			alert("You must accept the terms!");
		}
	};
	
	this.setInputIds = function(usernameId, passwordId, signupUsername, signupEmail, signupPassword) {

		_login.username = $("#" + usernameId)[0];
		_login.password = $("#" + passwordId)[0];
		_signup.username = $("#" + signupUsername)[0];
		_signup.email = $("#" + signupEmail)[0];
		_signup.password = $("#" + signupPassword)[0];

		_signup.checkbox = $("#sign-up input[type=checkbox]")[0];

		_login.username.onkeyup = submitLoginByKey;
		_login.password.onkeyup = submitLoginByKey;

		_signup.username.onkeyup = submitSignupByKey;
		_signup.email.onkeyup = submitSignupByKey;
		_signup.password.onkeyup = submitSignupByKey;

		_login.username.focus();
	};
};

$(document).ready(function() {
	WCLogin.setInputIds("username", "password", "signup-username", "signup-email", "signup-password");
});
