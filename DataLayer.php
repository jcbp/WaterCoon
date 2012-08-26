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
	private $routineName;
	private $arguments;

	private $xmlRoutine;

	function __construct() {
		$this->arguments = new AppArgs(AppArgs::GET);
		$this->responder = $this->getResponder();
		$errorDescription = str_replace('%param%', Config::ROUTINE_VAR_NAME, Config::NO_ROUTINE_ERROR);
		$this->routineName = $this->getVar(Config::ROUTINE_VAR_NAME, $errorDescription);

		$this->xmlRoutine = array(Config::ROUTINE_EXTRA_DEF, Config::ROUTINE_DEF);
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

	private function getVar($varName, $error, $nullable = false) {
		$value = null;
		if ($this->arguments->isVarExist($varName)) {
			$value = $this->arguments->getVar($varName);
		}
		// si no se encuentra en los argumentos, se lo busca en los datos de usuario alojados en la sesión
		else {
			if (isset($_SESSION["wc_username"][$varName])) {
				$value = $_SESSION["wc_username"][$varName];
			}
			// si no se obtuvo el valor y no admite un valor nulo, se muestra un error y se termina la ejecución
			else if (!$nullable) {
				$this->responder->respond($error);
			}
		}
		return $value;
	}

	private function addQuotesIfString($value) {
		$ret = $value;
		if (!preg_match('/^\d+$/', $value, $matches)) {
			$ret = "'" . $value . "'";
		}
		return $ret;
	}

	private function getXmlObjRoutine($xmlFile) {
		$info = null;
		$xml = simplexml_load_file($xmlFile);
		foreach ($xml->children() as $routine) {
			if (((string)$routine->name) == $this->routineName) {
				$info = $routine;
				break;
			}
		}
		return $info;
	}

	public function getRoutineInfo() {
		$info = null;
		for ($i = 0; $i < sizeof($this->xmlRoutine) && $info == null; $i++) {
			$info = $this->getXmlObjRoutine($this->xmlRoutine[$i]);
		}
		return $info;
	}

	public function buildSQLQuery($info) {
		$sql = "call $this->routineName(";
		foreach ($info->arguments->children() as $argument) {
			$param = $this->getVar((string)$argument, str_replace("%param%", $argument, Config::MISSING_PARAMETER), (boolean)$argument['nullable']);
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
