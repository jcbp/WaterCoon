
/**
 * Custom Cell Editor: ComboBox
 */
var ComboBoxEditor = function(args) {

    var _control;
    var _valueChanged = false;
    var _items = {};

    var init = function() {
		_control = document.createElement("select");
		_control.className = "combobox-editor";
		var items = args.column.values.split(",");
		for (var i = 0; i < items.length; i++) {
			addItem(items[i], i);
		};
		_control.onchange = onValueChange;
		args.container.appendChild(_control);
		_control.focus();
    };

    var addItem = function(text, value) {
    	var item = document.createElement("option");
    	item.innerHTML = text;
		item.value = value || _control.options.length;
    	_control.appendChild(item);
    	_items[text] = _control.options.length - 1;
    };

    var getSelectedItem = function() {
		return _control.options[_control.selectedIndex].text;
    };

    var selectItem = function(text) {
    	if (!(text in _items)) {
    		addItem(text);
    	}
    	_control.selectedIndex = _items[text];
    };

    var onValueChange = function(e) {
    	_valueChanged = true;
    };

    this.destroy = function() {
        args.container.removeChild(_control);
    };

    this.focus = function() {
        _control.focus();
    };

    this.isValueChanged = function() {
        return _valueChanged;
    };

    this.serializeValue = function() {
        return getSelectedItem();
    };

    this.loadValue = function(item) {
        selectItem(item[args.column.id]);
    };

    this.applyValue = function(item, state) {
		item[args.column.field] = state;
    };

    this.validate = function() {
        return {valid: true, msg: null};
    };

    init();
};

var objectIsEmpty = function(obj) {
	var isEmpty = true;
	for (var i in obj) {
		if (obj.hasOwnProperty(i)) {
			isEmpty = false;
			break;
		}
	};
	return isEmpty;
};

var copy = function(objA, objB) {
	for (var i in objB) {
		if (objB.hasOwnProperty(i) && objB[i] !== null) {
			objA[i] = objB[i];
		}
	};
	return objA;
};

var Synchronizer = function(requirementIds) {
	
	var _callbacks = [];
	var _requirements = {};
	var _data = {};
	
	for (var i=0; i<requirementIds.length; i++) {
		_requirements[requirementIds[i]] = 1;
	}
	
	var callFunctions = function() {
		for (var i=0; i<_callbacks.length; i++) {
			if (_callbacks[i] instanceof Function) {
				_callbacks[i](_data);
			}
		}
	};
	
	this.notify = function(callback) {
		_callbacks.push(callback);
	};
	
	this.commit = function(id, data) {
		_data[id] = typeof data=="undefined" ? null : data;
		delete _requirements[id];
		if (objectIsEmpty(_requirements)) {
			callFunctions();
		}
	};
};

/**
 * Administra la grilla de datos
 * @namespace
 */
var WCGrid = new function() {
	
	this.DataConverter = function() {

		var sortByOrderIndex = function(dataSet) {
			dataSet.sort(function(a, b) {
				return a.order_index - b.order_index;
			});
			return dataSet;
		};

		var getIdColumn = function() {
			var idColumn = {
				id: "id",
				name: "#",
				field: "id",
				width: 40,
				cssClass: "cell-selection",
				cannotTriggerInsert: true,
				resizable: false,
				selectable: false,
				focusable: false,
				order_index: 0
			};
			return idColumn;
		};
		
		this.convertColumnData = function(data) {
			data = sortByOrderIndex(data);
			var columns = [getIdColumn()];

			for (var i=0; i<data.length; i++) {
				var row = data[i];
				var column = {
					id: row.field_id,
					name: row.name,
					field: row.field_id,
					field_type: row.field_type,
					default_value: row.default_value,
					values: row.values,
					order_index: row.order_index
				};
				columns.push(column);
			}
			return columns;
		};

		this.convertRowData = function(data) {
			var ret = [];
			var issues = {};
			
			for (var i=0; i<data.length; i++) {
				var issue;
				if (issues[data[i].issue_id]) {
					issue = issues[data[i].issue_id];
				}
				else {
					issue = issues[data[i].issue_id] = {
						order_index: data[i].order_index,
						id: data[i].issue_id,
						field_value_id: {}
					};
				}
				issue.field_value_id[data[i].field_id] = data[i].field_value_id;
				issue[data[i].field_id] = data[i].value;
			};
			for (var i in issues) {
				if (issues.hasOwnProperty(i)) {
					ret.push(issues[i]);
				}
			};
			ret = sortByOrderIndex(ret);
			return ret;
		};
	};

	// null for default control
	var FieldType = {
		"text": {
			editor: Slick.Editors.Text,
			formatter: null,
			validator: null
		},
		"longText": {
			editor: Slick.Editors.LongText
			//editor: AltLongTextEditor
		},
		"boolean": {
			editor: Slick.Editors.Checkbox,
			formatter: Slick.Formatters.Checkmark
		},
		"date": {
			editor: Slick.Editors.Date
		},
		"user": {
			// combobox: falta armar el control
			editor: ComboBoxEditor
		},
		"customList": {
			// combobox: falta armar el control
			// editor: Slick.Editors.Text
			editor: ComboBoxEditor
		},
		"percent": {
			editor: Slick.Editors.PercentComplete
		}
	};

	var MenuCommand = {
		InsertToLeft: "insert-left",
		InsertToRight: "insert-right",
		DeleteColumn: "delete-column",
		EditColumn: "edit-column"
	};
	this.MenuCommand = MenuCommand;

	var HeaderMenuOptions = [
		{
			title: "Insert Column To Left",
			command: MenuCommand.InsertToLeft
		}, {
			title: "Insert Column To Right",
			command: MenuCommand.InsertToRight
		}, {
			title: "Delete Column",
			command: MenuCommand.DeleteColumn
		}, {
			title: "Edit Column",
			command: MenuCommand.EditColumn
		}
	];

	var GridConfig = {
		editable: true,
		autoEdit: false,
		enableAddRow: true,
		forceFitColumns: true,
		enableCellNavigation: true,
		enableColumnReorder: true,
		topPanelHeight: 300
	};
		
	this.DataGrid = function(columns, rows, containerSelector) {
		
		var _event = new EventDispatcher(this);
		var _grid;
		var _headerMenuPlugin;

		var init = function() {
			settingColumns();
			_grid = new Slick.Grid(containerSelector, rows, columns, GridConfig);
			_headerMenuPlugin = new Slick.Plugins.HeaderMenu({});
			_headerMenuPlugin.onCommand.subscribe(menuCommandHandler);
			_grid.registerPlugin(_headerMenuPlugin);
			_grid.onCellChange.subscribe(updateFieldValue);
			_grid.onAddNewRow.subscribe(createIssue);
			_grid.onHeaderDblClick.subscribe(editColumn);

			$("#inline-panel").appendTo(_grid.getTopPanel()).show();
		};

		var editColumn = function() {
			
		};

		var setColumnMenu = function(column) {
			column.header = {
				menu: {
					items: HeaderMenuOptions
				}
			};
		};

		var setColumnType = function(column) {
			copy(column, FieldType[column.field_type]);
		};

		var setColumnId = function(column) {
			if (!column.id && column.field_id) {
				column.id = column.field_id;
				column.field = column.field_id;
			}
		};

		var settingColumns = function() {
			for (var i = 0; i < columns.length; i++) {
				setColumnMenu(columns[i]);
				setColumnType(columns[i]);
			};
		};

		var menuCommandHandler = function(e, args) {
			_event.dispatchEvent("headerMenuCommand", args.command, parseInt(args.column.order_index));
		};

		var updateFieldValue = function(e, args) {
			var fieldId = args.grid.getColumns()[args.cell].id;
			var fieldValueId = args.item.field_value_id[fieldId];
			var issueId = args.item.id;
			_event.dispatchEvent("updateCell", issueId, fieldId, fieldValueId, null, args.item[fieldId]);
		};

		var createIssue = function (e, args) {
			var value = args.item[args.column.id];
			_event.dispatchEvent("newRow", rows.length + 1, args.column.id, null, value);
		};

		var reorderColumns = function(index) {
			for (var i = 0; i < columns.length; i++) {
				if (columns[i].order_index >= index) {
					columns[i].order_index++;
				}
			};
		};

		this.addRow = function(row) {
			rows.push(row);
			_grid.invalidateRows([rows.length - 1]);
			_grid.updateRowCount();
			_grid.render();
		};

		this.addColumn = function(column, orderIndex) {
			reorderColumns(orderIndex);
			setColumnMenu(column);
			setColumnType(column);
			setColumnId(column);
			columns.splice(orderIndex, 0, column);
			_grid.setColumns(columns);
		};

		this.showTopPanel = function() {
			_grid.showTopPanel();
		};

		this.hideTopPanel = function() {
			_grid.hideTopPanel();
		};

		this.addEventListener = function(eventName, callback) {
			_event.addEventListener(eventName, callback);
		};

		init();
	};
};

var EventDispatcher = function(obj) {
	
	var _obj = obj || {};
	var _events = {};

	this.addEventListener = function(eventName, callback) {
		if (!_events[eventName]) {
			_events[eventName] = [];
		}
		_events[eventName].push(callback);
	};

	this.removeEventListener = function(eventName, callback) {
		for (var i = 0; i < _events[eventName].length; i++) {
			if (_events[eventName][i] == callback) {
				_events[eventName].splice(i, 1);
			}
		};
		if (_events[eventName].length == 0) {
			delete _events[eventName];
		}
	};

	this.dispatchEvent = function(eventName) {
		if (_events[eventName]) {
			for (var i = 0; i < _events[eventName].length; i++) {
				if (_events[eventName][i]) {
					var args = Array.prototype.slice.call(arguments, 1);
					_events[eventName][i].apply(_obj, args);
				}
			};
		}
	};
};

var JSONPDataSource = function(globalConfig) {

	var globalConfig = {
		url: "DataLayer.php",
		dataType: "jsonp",
		type: "GET",
		jsonp: "jsonp",
		timeout: 5000
	};

	this.setOnError = function(callback) {
		globalConfig.error = callback;
	};
	
	this.request = function(data, callback) {
		var config = copy({}, globalConfig);
		config.data = data;
		config.success = callback;
		$.ajax(config);
	};
};

var TransactionManager = function(dataSource) {

	var _event = new EventDispatcher(this);
	
	var performTransaction = function(routineName, params, resultCallback) {
		var data = params || {};
		for (var i in params) {
			if (params.hasOwnProperty(i) && params[i] === null) {
				delete params[i];
			}
		};
		data.exec = routineName;
		dataSource.request(data, resultCallback);
	};

	var dispatchEvent = function(name, callback, data, status) {
		_event.dispatchEvent(name, data, status);
		if (callback) {
			callback(data, status);
		}
	};

	this.getProject = function(callback) {
		performTransaction("get_project_by_user_id", null, function(data, status) {
			dispatchEvent("getProject", callback, data, status);
		});
	};

	this.getSheet = function(projectId, callback) {
		performTransaction("get_sheet_by_project_id", { project_id: projectId }, function(data, status) {
			dispatchEvent("getSheet", callback, data, status);
		});
	};

	this.getSheetData = function(sheetId, callback) {
		var synchronizer = new Synchronizer(["column", "row"]);
		synchronizer.notify(function(data, status) {
			dispatchEvent("getSheetData", callback, data, status);
		});
		performTransaction("get_field_by_sheet_id", { sheet_id: sheetId }, function(data, status) {
			synchronizer.commit("column", data, status);
		});
		performTransaction("get_field_value_by_sheet_id", { sheet_id: sheetId }, function(data, status) {
			synchronizer.commit("row", data, status);
		});
	};

	this.getFieldType = function(callback) {
		performTransaction("get_field_type", null, function(data, status) {
			dispatchEvent("getFieldType", callback, data, status);
		});
	};

	this.insertFieldValue = function(orderIndex, fieldId, userId, value, callback) {
		performTransaction("insert_issue_and_field_value", {
			order_index: orderIndex,
			field_id: fieldId,
			user_id: userId,
			value: value
		}, function(data, status) {
			dispatchEvent("insertFieldValue", callback, data, status);
		});
	};

	this.insertField = function(sheetId, fieldTypeId, orderIndex, name, values, defaultValues, callback) {
		performTransaction("insert_field_with_order_index", {
			sheet_id: sheetId,
			field_type_id: fieldTypeId,
			order_index: orderIndex,
			name: name,
			values: values,
			default_value: defaultValues
		}, function(data, status) {
			dispatchEvent("insertField", callback, data, status);
		});
	};

	this.insertProject = function(name, callback) {
		performTransaction("insert_project_with_user", { name: name }, function(data, status) {
			dispatchEvent("insertProject", callback, data, status);
		});
	};

	this.insertSheet = function(projectId, name, callback) {
		performTransaction("insert_sheet_with_user", {
			project_id: projectId,
			name: name
		}, function(data, status) {
			dispatchEvent("insertSheet", callback, data, status);
		});
	};

	this.updateFieldValue = function(fieldValueId, sheetId, fieldId, userId, value, issueId, callback) {
		if (fieldValueId) {
			performTransaction("update_field_value", {
				field_value_id: fieldValueId,
				user_id: userId,
				value: value
			}, function(data, status) {
				dispatchEvent("updateFieldValue", callback, data, status);
			});
		}
		else {
			performTransaction("insert_field_value", {
				field_value_id: 0,
				sheet_id: sheetId,
				field_id: fieldId,
				user_id: userId,
				value: value,
				issue_id: issueId
			}, function(data, status) {
				dispatchEvent("updateFieldValue", callback, data, status);
			});
		}
	};

	this.addEventListener = function(eventName, callback) {
		_event.addEventListener(eventName, callback);
	};

	this.removeEventListener = function(eventName, callback) {
		_event.removeEventListener(eventName, callback);
	};
};

var ApplicationUI = function() {
	
	var _dataSource = new JSONPDataSource();
	var _transaction = new TransactionManager(_dataSource);
	var _converter = new WCGrid.DataConverter();
	var _currentProject = null;
	var _currentSheet = null;
	var _currentDataGrid = null;

	var _columnDialog = new ColumnDialog();

	_dataSource.setOnError(function() {
		alert("Request error!");
	});

	var addProject = function(id, name) {
		$("#project").append(new Option(name, id));
	};

	var addSheet = function(id, name) {
		new Tab(id, name);
	};

	var updateFieldValue = function(issueId, fieldId, fieldValueId, userId, value) {
		_transaction.updateFieldValue(fieldValueId, _currentSheet, fieldId, userId, value, issueId);
	};

	var createIssue = function(orderIndex, fieldId, userId, value) {
		_transaction.insertFieldValue(orderIndex, fieldId, userId, value, function(data, status) {
			var row = _converter.convertRowData(data);
			_currentDataGrid.addRow(row[0]);
		});
	};

	var createColumn = function(orderIndex, formData) {
		_transaction.insertField(_currentSheet, formData.type, orderIndex, formData.name, formData.values, formData.defaultValue, function(data, status) {
			_currentDataGrid.addColumn(data[0], orderIndex);
			_currentDataGrid.hideTopPanel();
		});
	};

	var showColumnCreationForm = function(orderIndex) {
		_transaction.getFieldType(function(data, status) {
			_currentDataGrid.showTopPanel();
			_columnDialog.showDialog(data, function(formData) {
				createColumn(orderIndex, formData);
			});
		});
	};

	var headerMenuHandler = function(command, orderIndex) {
		switch(command) {
			case WCGrid.MenuCommand.InsertToLeft:
				showColumnCreationForm(orderIndex);
				break;
			case WCGrid.MenuCommand.InsertToRight:
				showColumnCreationForm(orderIndex + 1);
				break;
			case WCGrid.MenuCommand.DeleteColumn:
				alert("delete");
				break;
			case WCGrid.MenuCommand.EditColumn:
				alert("edit");
				break;
			default:
				// ???
				break;
		}
	};

	this.loadSheetData = function(sheetId) {
		_transaction.getSheetData(sheetId, function(data, status) {
			var columns = _converter.convertColumnData(data.column);
			var rows = _converter.convertRowData(data.row);
			_currentDataGrid = new WCGrid.DataGrid(columns, rows, "#data-grid");
			_currentDataGrid.addEventListener("headerMenuCommand", headerMenuHandler);
			_currentDataGrid.addEventListener("updateCell", updateFieldValue);
			_currentDataGrid.addEventListener("newRow", createIssue);
			_currentSheet = sheetId;
		});
	};

	this.loadProjects = function() {
		_transaction.getProject(function(data, status) {
			for (var i = 0; i < data.length; i++) {
				addProject(data[i].project_id, data[i].name);
			}
		});
	};

	this.loadProjectSheets = function() {
		_transaction.getSheet(_currentProject, function(data, status) {
			for (var i = 0; i < data.length; i++) {
				addSheet(data[i].sheet_id, data[i].name);
			}
		});
	};

	this.createProject = function(name) {
		_transaction.insertProject(name, function(data, status) {
			addProject(data[0].project_id, data[0].name);
		});
	};

	this.createSheet = function(name) {
		if (_currentProject) {
			_transaction.insertSheet(_currentProject, name, function(data, status) {
				addSheet(data[0].sheet_id, data[0].name);
			});
		}
	};

	this.selectProject = function(id) {
		_currentProject = id;
	};

	this.addEventListener = function(eventName, callback) {
		_transaction.addEventListener(eventName, callback);
	};
};

var ColumnDialog = function() {

	var _onSubmit = null;

	var createColumn = function() {
		if (_onSubmit) {
			var formData = {};
			formData.name = $("#column-name").val();
			formData.type = $(".tmp-column-creator select").val();
			formData.values = $(".tmp-column-creator textarea").val().replace(/\n/g, ",");
			formData.defaultValue = $("#def-value").val();
			_onSubmit(formData);
		}
		$(".tmp-column-creator").css("display", "none");
	};

	this.showDialog = function(fieldTypes, onFinish) {
		_onSubmit = onFinish;
		var select = $(".tmp-column-creator select");
		for (var i = 0; i < fieldTypes.length; i++) {
			var option = new Option(fieldTypes[i].description, fieldTypes[i].field_type_id);
			select.append(option);
		};
		$(".tmp-column-creator")[0].style.display = "block";
	};

	$("#create-column").on("click", createColumn);

	$("#cancel-column").on("click", function() {
		$(".tmp-column-creator").css("display", "none");
	});
};

var Tab = function(sheetId, title) {
	var tabs = document.getElementById("tabs");
	var tab = document.createElement("li");
	tab.innerHTML = title;
	tab.style.cursor = "pointer";
	tab.onclick = function() {
		appUI.loadSheetData(sheetId);
	};
	tabs.appendChild(tab);
};

var selectProject = function() {
	var tabs = document.getElementById("tabs");
	tabs.innerHTML = "";
	selectedProject = $("#project").val();

	appUI.selectProject(selectedProject);
	appUI.loadProjectSheets();
};

var createProject = function(obj) {
	var projectInput = document.getElementById("project-name");
	if (projectInput.value) {
		appUI.addEventListener("insertProject", function() {
			obj.removeAttribute("disabled");
		});
		appUI.createProject(projectInput.value);

		projectInput.value = "";
		obj.disabled = "disabled";
	}
};

var createSheet = function(obj) {
	var sheetInput = document.getElementById("sheet-name");
	if (sheetInput.value) {
		appUI.addEventListener("insertSheet", function() {
			obj.removeAttribute("disabled");
		});
		appUI.createSheet(sheetInput.value);

		sheetInput.value = "";
		obj.disabled = "disabled";
	}
};

var logout = function(src) {
	var req = new Image();
	var redirect = function() {
		location.reload();
	};
	req.onload = redirect;
	req.onerror = redirect;
	req.src = src;
};

var appUI;

$(document).ready(function() {
	appUI = new ApplicationUI();
	appUI.loadProjects();
	
	//columnDialog = new ColumnDialog();
});
