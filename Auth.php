<?php

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

	function __construct()
	{
		$this->arguments = new AppArgs(AppArgs::GET);
		$this->getResponder();

		if (!$this->arguments->isVarExist('username', true) || !$this->arguments->isVarExist('password', true)) {
			$this->responder->respond("Invalid username or password");
		}

		$this->normalizeStrings();
		$this->query();
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

	private function normalizeStrings() {
		$this->username = $this->arguments->getVar('username'); 
		$this->password = $this->arguments->getVar('password'); 
		$this->username = stripslashes($this->username);
		$this->password = stripslashes($this->password);
		$this->username = mysql_real_escape_string($this->username);
		$this->password = mysql_real_escape_string($this->password);
	}
	
	private function query() {
		$query = "call get_user_by_name('" . $this->username . "')";
		$dbconn = new DBConnection(Config::DB_CONFIG, $this->responder);
		$this->queryResult = $dbconn->query($query);
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
