<?php

session_start();
if (!isset($_SESSION["wc_username"])) {
	die("You must be logged in");
}

include 'classes/Config.php';
include 'classes/DBConnection.php';
include 'classes/WebResponder.php';
include 'classes/AppArgs.php';

/**
 * Capa de datos
 **/
class DataLayer {
	
	private $responder;
	private $routines;
	private $routineName;
	private $arguments;

	function __construct() {
		$this->arguments = new AppArgs(AppArgs::GET);
		$this->responder = $this->getResponder();
		$errorDescription = str_replace('%param%', Config::ROUTINE_VAR_NAME, Config::NO_ROUTINE_ERROR);
		$this->routineName = $this->getVar(Config::ROUTINE_VAR_NAME, $errorDescription);

		$this->routines = array();
		$this->loadRoutineDefinition(Config::ROUTINE_DEF);
		$this->loadRoutineDefinition(Config::ROUTINE_EXTRA_DEF);
	}

	private function getResponder() {
		if ($this->arguments->isVarExist(Config::JSONP_VAR_NAME)) {
			$responder = new JSONPResponder();
			$responder->setFunctionName($this->arguments->getVar(Config::JSONP_VAR_NAME));
		}
		else {
			$responder = new JSONResponder();
		}
		return $responder;
	}

	private function getVar($varName, $error) {
		$value = null;
		if (!$this->arguments->isVarExist($varName)) {
			// si no se encuentra en los argumentos, se lo busca en los datos de usuario alojados en la sesión
			if (isset($_SESSION["wc_username"][$varName])) {
				$value = $_SESSION["wc_username"][$varName];
			}
			else {
				$this->responder->respond($error);
			}
		}
		else {
			$value = $this->arguments->getVar($varName);
		}
		return $value;
	}

	private function loadRoutineDefinition($xmlName) {
		$xml = simplexml_load_file($xmlName);
		foreach ($xml->children() as $routine) {
			$routineName = (string)$routine->name;
			$this->routines[$routineName] = array();
			foreach($routine->arguments->children() as $argument) {
				array_push($this->routines[$routineName], $argument);
			}
		}
	}

	private function addQuotesIfString($value) {
		$ret = $value;
		if (!preg_match('/^\d+$/', $value, $matches)) {
			$ret = "'" . $value . "'";
		}
		return $ret;
	}

	public function getRoutineInfo() {
		$routineInfo = null;
		if (isset($this->routines[$this->routineName])) {
			$routineInfo = $this->routines[$this->routineName];
		}
		else {
			$this->responder->respond(str_replace("%name%", $this->routineName, Config::INVALID_ROUTINE));
		}
		return $routineInfo;
	}

	public function buildSQLQuery($info) {
		$sql = "call $this->routineName(";
		for ($i=0; $i<sizeof($info); $i++) {
			$param = $this->getVar((string)$info[$i], str_replace("%param%", $info[$i], Config::MISSING_PARAMETER));
			$sql .= $this->addQuotesIfString($param) . ", ";
		}
		$sql = rtrim($sql, ", ");
		$sql .= ")";
		return $sql;
	}

	public function performQuery($query) {
		try {
			$dbconn = new DBConnection(Config::DB_CONFIG, $this->responder);
			$result = $dbconn->query($query);
			$resultArray = $dbconn->resultsetToArray($result);
			$dbconn->close();
		}
		catch (Exception $e) {
			$this->responder->respond($e->getMessage());
		}
		$this->responder->respond(json_encode($resultArray));
	}
}

$dataLayer = new DataLayer();
$routineInfo = $dataLayer->getRoutineInfo();
$sqlQuery = $dataLayer->buildSQLQuery($routineInfo);
$dataLayer->performQuery($sqlQuery);

?>
