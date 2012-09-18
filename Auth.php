<?php

include 'classes/GlobalErrorHandler.php';
include 'classes/Config.php';
include 'classes/DBConnection.php';
include 'classes/WebResponder.php';
include 'classes/AppArgs.php';

class Auth {

	private $arguments;
	private $responder;
	private $username;
	private $password;
	private $queryResult;

	function __construct() {
		$this->arguments = new AppArgs(AppArgs::GET);
		$this->getResponder();

		if (!$this->arguments->isVarExist('username', true) || !$this->arguments->isVarExist('password', true)) {
			$this->responder->respond("Invalid username or password");
		}

		$this->performQuery();
		$this->authenticate();
	}

	private function getResponder() {
		if ($this->arguments->isVarExist(Config::JSONP_VAR_NAME)) {
			$this->responder = new JSONPResponder();
			$this->responder->setFunctionName($this->arguments->getVar(Config::JSONP_VAR_NAME));
		}
		else {
			$this->responder = new JSONResponder();
		}
	}

	private function escapeStrings($conn) {
		$this->username = $conn->escapeString($this->arguments->getVar('username')); 
		$this->password = $conn->escapeString($this->arguments->getVar('password')); 
	}

	private function buildQuery($conn) {
		$this->escapeStrings($conn);
		return "call get_user_by_name('" . $this->username . "')";
	}

	private function performQuery() {
		$dbconn = new DBConnection(Config::DB_CONFIG, $this->responder);
		$this->queryResult = $dbconn->query($this->buildQuery($dbconn));
		$dbconn->close();
	}

	private function authenticate() {
		$row = mysqli_fetch_assoc($this->queryResult);
		if (crypt($this->password, $row["password"]) == $row["password"]) {
			session_start();
			unset($row["password"]);
			$_SESSION["wc_username"] = $row;
			$this->responder->respond("success");
		}
		else {
			$this->responder->respond("authentication failure");
		}
	}
}

new Auth();

?>
