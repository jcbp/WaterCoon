<!DOCTYPE html>
<html>

<head>
	<title>WaterCoon</title>
	<meta http-equiv="content-type" content="text/html;charset=utf-8" />
	
	<link href="css/login.css" rel="stylesheet" type="text/css">
	
	<script src="slickgrid/lib/jquery-1.7.min.js"></script>
	<script src="login.js"></script>
</head>

<body>
	<div id="header" class="wc-fst-gradient">
		
	</div>
	<div id="content">
		<div id="sign-in" class="container">
			<div class="title">Sign In</div>
			<input name="user" type="text" id="username" placeholder="Username"><br />
			<input name="pass" type="password" id="password" placeholder="Password">
			<br />
			<a href="#">Forgot your password?</a>
			<input type="submit" name="Submit" class="submit-button" value="Sign in" onclick="WCLogin.submit()">
		</div>
		<div class="separator"></div>
		<div id="sign-up" class="container">
			<div class="title">Sign up</div>
			<input name="signup-user" type="text" id="signup-username" placeholder="Username"><br />
			<input name="signup-email" type="text" id="signup-email" placeholder="E-mail"><br />
			<input name="signup-pass" type="password" id="signup-password" placeholder="Password">
			<span>
				<input type="checkbox">
				I accept the <a href="#">Terms of Service</a>
			</span>
			<input type="submit" name="signup-submit" class="submit-button" value="Sign up" onclick="WCLogin.submitSignup()">
		</div>
	</div>
	<div id="footer"></div>
</body>

</html>
