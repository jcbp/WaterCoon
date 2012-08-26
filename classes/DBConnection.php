<?php

include_once 'log4php/Logger.php';
Logger::configure('xml/log4php_config.xml');

function encodeItemsToUtf8(&$item, $key) {
	$item = utf8_encode($item);
}

/**
 * Maneja la conección con la Base de Datos
 **/
class DBConnection {
	
	private $log;
	private $connection;

	function __construct($xmlConfigFile) {
		$this->log = Logger::getLogger("DBConnection");
		$xml = simplexml_load_file($xmlConfigFile);
		$children = $xml->appsettings->children();
		$this->connection = new mysqli($children->servername, $children->username, $children->password, $children->database, (int)$children->serverport);
		$this->checkForConnectionError();
	}

	private function checkForConnectionError() {
		$error = $this->connection->connect_error;
		if ($error) {
			$this->log->error($error);
			throw new Exception($error);
		}
	}

	public function query($query) {
		$result = $this->connection->query($query);
		if (!$result) {
			$this->log->error("Error to '$query': " . $this->connection->error);
			throw new Exception("Error to '$query': " . $this->connection->error);
		}
		else if (gettype($result) == "boolean" && $result) {
			$this->log->info("Successful operation");
		}
		return $result;
	}

	public function resultsetToArray($result) {
		$ret = array();
		if (gettype($result) != "boolean") {
			while ($row = $result->fetch_assoc()) {
				array_push($ret, $row);
			}
			array_walk_recursive($ret, 'encodeItemsToUtf8');
			$result->free();
		}
		return $ret;
	}

	public function close() {
		$this->connection->close();
	}

	function __destruct() {
		@$this->connection->close();
	}
}

?>
