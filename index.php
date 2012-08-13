<!DOCTYPE HTML>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8">

	<title>WaterCoon</title>
	<script src="slickgrid/lib/firebugx.js"></script>

	<script src="slickgrid/lib/jquery-1.7.min.js"></script>
	<script src="slickgrid/lib/jquery-ui-1.8.16.custom.min.js"></script>
	<script src="slickgrid/lib/jquery.event.drag-2.0.min.js"></script>

	<script src="slickgrid/slick.core.js"></script>
	<script src="slickgrid/plugins/slick.cellrangedecorator.js"></script>
	<script src="slickgrid/plugins/slick.cellrangeselector.js"></script>
	<script src="slickgrid/plugins/slick.cellselectionmodel.js"></script>
	<script src="slickgrid/plugins/slick.rowselectionmodel.js"></script>
	<script src="slickgrid/plugins/slick.rowmovemanager.js"></script>
	<script src="slickgrid/slick.formatters.js"></script>
	<script src="slickgrid/slick.editors.js"></script>
	<script src="slickgrid/slick.grid.js"></script>
	<script src="watercoon.js" type="text/javascript" charset="utf-8"></script>

	<link rel="stylesheet" href="slickgrid/slick.grid.css" type="text/css"/>
	<link rel="stylesheet" href="slickgrid/css/smoothness/jquery-ui-1.8.16.custom.css" type="text/css"/>
	<link rel="stylesheet" href="slickgrid/examples/examples.css" type="text/css"/>

	<style>

	body {
		background-color: #ffffff;
		font-size: 16px;
		font-family: arial;
	}

	div {
		font-size: 14px !important;
	}

	input {
		padding: 3px 10px;
	}

	select {
		padding: 3px;
	}

	a {
		font-size: 14px;
		text-decoration: none;
	}

	li {
		font-size: 12px;
	}

	.alt-long-text-editor {
		width: 92%;
		height: 92%;
		left: 4%;
		top: 5%;
		z-index: 100;
		text-align: center;
		background-color: white;
		position: absolute;
		border: 2px solid black;
	}

	.text-editor-control {
		width: 98%;
		height: 90%;
		margin-left: auto;
		margin-right: auto;
		margin-top: 10px;
	}

	.cell-selection {
		border-right-color: silver;
		border-right-style: solid;
		background: #EBEBEB;
		color: gray;
		text-align: right;
		font-size: 10px;
	}

	.combobox-editor {
		width: 90%;
		height: 20px;
	}

	</style>

</head>
<body>
	<?php
	session_start();
	if (isset($_SESSION["wc_username"])) {
		echo "Bienvenido " . $_SESSION["wc_username"]["username"];
	}
	else {
		header("Location: login.php");
	}
	?>
	<br />
	<a href="#" onclick="logout('logout.php')">Logout</a>
	<br />
	<hr />
	<div style="display: inline-block; width: 350px">
		Project <select name="project" id="project"></select>
		<input type="button" value="select" onclick="selectProject()">
	</div>
	<input id="project-name" type="text" placeholder="Project Name">
	<input type="button" value="Create Project" onclick="createProject(this)" style="width: 90px">
	<br />
	<br />
	<br />
	<br />
	<div style="display: inline-block; width: 350px">
		Sheets:
	</div>
	<input id="sheet-name" type="text" placeholder="Sheet Name">
	<input type="button" value="Create Sheet" onclick="createSheet(this)" style="width: 90px"><br />
	<ul id="tabs"></ul><br />
	<div id="data-grid" style="height: 600px"></div>

</body>
