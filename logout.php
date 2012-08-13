<?php
session_start();
unset($_SESSION["wc_username"]);
session_destroy();
?>
