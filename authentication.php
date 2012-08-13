<?php

include 'classes/Config.php';
include 'classes/DBConnection.php';
include 'classes/WebResponder.php';
include 'classes/AppArgs.php';

$arguments = new AppArgs(AppArgs::GET);

function getResponder() {
	global $arguments;
	if ($arguments->isVarExist(Config::JSONP_VAR_NAME)) {
		$responder = new JSONPResponder();
		$responder->setFunctionName($arguments->getVar(Config::JSONP_VAR_NAME));
	}
	else {
		$responder = new JSONResponder();
	}
	return $responder;
}

$responder = getResponder();

if (!$arguments->isVarExist('username', true) || !$arguments->isVarExist('password', true)) {
	$responder->respond("Invalid username or password");
}

$username = $arguments->getVar('username'); 
$password = $arguments->getVar('password'); 
$username = stripslashes($username);
$password = stripslashes($password);
$username = mysql_real_escape_string($username);
$password = mysql_real_escape_string($password);

$query = "call get_user_by_name('" . $username . "')";
$dbconn = new DBConnection(Config::DB_CONFIG, $responder);
$result = $dbconn->query($query);
$dbconn->close();

$row = mysqli_fetch_assoc($result);
if ($row["password"] == $password) {
	session_start();
	unset($row["password"]);
	$_SESSION["wc_username"] = $row;
	$responder->respond("success");
}
else {
	$responder->respond("authentication failure");
}

?>
