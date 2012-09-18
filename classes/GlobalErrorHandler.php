<?php

include_once 'log4php/Logger.php';
Logger::configure('xml/log4php_config.xml');

function globalErrorHandler($errno, $errstr, $errfile, $errline) {
	$log = Logger::getLogger("GlobalErrorHandler");
	
	switch ($errno) {
		case E_USER_WARNING:
			$log->warn($errstr . "\tfile: $errfile\tline: $errline");
			break;
		case E_USER_ERROR:
			$log->error($errstr . "\tfile: $errfile\tline: $errline");
			break;
		default:
			$log->info($errstr . " [$errno]\tfile: $errfile\tline: $errline");
			break;
	}
}

set_error_handler("globalErrorHandler");

?>
