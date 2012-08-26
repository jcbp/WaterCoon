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
	<script src="slickgrid/plugins/slick.headermenu.js"></script>
	<script src="css-class-creator.js" type="text/javascript" charset="utf-8"></script>
	<script src="watercoon.js" type="text/javascript" charset="utf-8"></script>

	<link rel="stylesheet" href="slickgrid/slick.grid.css" type="text/css"/>
	<link rel="stylesheet" href="slickgrid/css/smoothness/jquery-ui-1.8.16.custom.css" type="text/css"/>
	<link rel="stylesheet" href="slickgrid/examples/examples.css" type="text/css"/>
	<link rel="stylesheet" href="slickgrid/plugins/slick.headermenu.css" type="text/css"/>

  <style>
    /**
     * Style the drop-down menu here since the plugin stylesheet mostly contains structural CSS.
     */

    .slick-header-menu {
      border: 1px solid #718BB7;
      background: #f0f0f0;
      padding: 2px;
      -moz-box-shadow: 2px 2px 2px silver;
      -webkit-box-shadow: 2px 2px 2px silver;
      min-width: 100px;
      z-index: 20;
    }


    .slick-header-menuitem {
      padding: 2px 4px;
      border: 1px solid transparent;
      border-radius: 3px;
    }

    .slick-header-menuitem:hover {
      border-color: silver;
      background: white;
    }

    .slick-header-menuitem-disabled {
      border-color: transparent !important;
      background: inherit !important;
    }

    .icon-help {
      background-image: url(../images/help.png);
    }
  </style>

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

	a:visited {
		color: #0000ee;
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

	.boolean-column {
		text-align: center;
	}

	.combobox-editor {
		width: 90%;
		height: 24px;
		font-size: 10px !important;
	}

	.tmp-column-creator {
		width: 400px;
		height: 550px;
		left: 50%;
		top: 100px;
		border: 2px solid gray;
		background-color: #eeeeee;
		position: absolute;
		margin-left: -200px;
		z-index: 1000;
		display: none;
		padding: 10px;
	}
	
	.tmp-column-creator * {
		width: 240px;
		padding: 5px 0px;
		margin-left: 10px;
		margin-top: 10px;
	}

	.tmp-column-creator div {
		width: 100px;
		height: 20px;
		display: inline-block;
	}

	.tmp-column-creator p {
		font-size: 14px;
		font-weight: bold;
	}

	.tmp-column-creator select {
		height: 120px;
	}

	.tmp-column-creator option {
		margin-top: 0px;
	}

	.tmp-column-creator textarea {
		height: 200px;
		font-size: 14px;
	}

	.tmp-button {
		width: 100px;
		float: right;
		margin-right: 35px;
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

	<div id="data-grid" style="height: 450px"></div>

	<div id="sheet-user">
		<p>Current Users</p>
		<div id="user-list"></div>
		<p>Add a new user to this sheet</p>
		<div id="add-user">
			<input placeholder="email" id="user-email">
			<select id="permission-list"></select>
			<input type="button" value="Add user" id="add-user-button">
		</div>
	</div>

	<div style="background-color: silver; height: 300px; display: none;" id="inline-panel">
		Inline Panel
	</div>

	<div class="tmp-column-creator">
		<p>Create Column</p>
		<div>Name</div><input id="column-name"><br/>
		<div>Type</div><select size="8"></select><br />
		<div>Values</div><textarea></textarea><br/>
		<div>Default</div><input id="def-value">
		<input class="tmp-button" type="button" value="Ok" id="create-column">
		<input class="tmp-button" type="button" value="Cancel" id="cancel-column">
	</div>

</body>
