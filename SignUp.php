<?php

include 'classes/Config.php';
include 'classes/DBConnection.php';
include 'classes/WebResponder.php';
include 'classes/AppArgs.php';

class SignUp {

	private $arguments;
	private $responder;
	private $username;
	private $email;
	private $password;

	function __construct()
	{
		$this->arguments = new AppArgs(AppArgs::GET);
		$this->getResponder();

		if (!$this->arguments->isVarExist('username', true) ||
			!$this->arguments->isVarExist('email', true) ||
			!$this->arguments->isVarExist('password', true)) {

			$this->responder->respond("Invalid username or password");
		}

		$this->normalizeStrings();
		$this->query();

		$this->responder->respond("success");
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
		$this->email = $this->arguments->getVar('email'); 
		$this->password = $this->arguments->getVar('password'); 
		$this->username = stripslashes($this->username);
		$this->email = stripslashes($this->email);
		$this->password = stripslashes($this->password);
		$this->username = mysql_real_escape_string($this->username);
		$this->email = mysql_real_escape_string($this->email);
		$this->password = mysql_real_escape_string($this->password);

		$this->password = crypt($this->password);
	}
	
	private function query() {
		try {
			$query = "call insert_user('$this->username', '$this->password', '$this->email')";
			$dbconn = new DBConnection(Config::DB_CONFIG, $this->responder);
			$this->queryResult = $dbconn->query($query);
			$dbconn->close();
		}
		catch (Exception $e) {
			$this->responder->respond($e->getMessage());
		}
	}
}

new SignUp();

?>
