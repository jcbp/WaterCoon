<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
	<title>WaterCoon</title>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	
	<link href="css/login.css" rel="stylesheet" type="text/css">
	
	<script src="slickgrid/lib/jquery-1.7.min.js"></script>
	<script src="login.js"></script>
</head>

<body>
	<div id="header">
		
	</div>
	<div id="separator"></div>
	<div id="content">
		<div>Sign In</div>
		<input class="login-input" name="user" type="text" id="username" placeholder="Username"><br />
		<input class="login-input" name="pass" type="password" id="password" placeholder="Password">
		<br />
		<a href="#">Forgot your password?</a>
		<input type="submit" name="Submit" id="submit-button" value="Sign in" onclick="WCLogin.submit()">
	</div>
	<div id="footer"></div>
</body>

</html>