<?php

include 'classes/GlobalErrorHandler.php';
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

		$this->performQuery();

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

	private function escapeStrings($conn) {
		$this->username = $conn->escapeString($this->arguments->getVar('username')); 
		$this->email = $conn->escapeString($this->arguments->getVar('email')); 
		$this->password = $conn->escapeString($this->arguments->getVar('password')); 
	}

	private function buildQuery($conn) {
		$this->escapeStrings($conn);
		$this->password = crypt($this->password);
		return "call insert_user('$this->username', '$this->password', '$this->email')";
	}
	
	private function performQuery() {
		try {
			$dbconn = new DBConnection(Config::DB_CONFIG, $this->responder);
			$this->queryResult = $dbconn->query($this->buildQuery($dbconn));
			$dbconn->close();
		}
		catch (Exception $e) {
			$this->responder->respond($e->getMessage());
		}
	}
}

new SignUp();

?>
