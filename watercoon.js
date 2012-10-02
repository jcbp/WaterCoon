
/**
 * Custom Cell Editor: ComboBox
 */
var ComboBoxEditor = function(args, keyValuePairs) {

    var _control;
    var _valueChanged = false;
    var _items = {};

    var init = function() {
		_control = document.createElement("select");
		_control.className = "combobox-editor";

		if (keyValuePairs) {
			for (var i = 0; i < keyValuePairs.length; i++) {
				addItem(keyValuePairs[i].key, keyValuePairs[i].value);
			};
		}
		else {
			var items = args.column.values.split(",");
			for (var i = 0; i < items.length; i++) {
				addItem(items[i], i);
			};
		}

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

var UserListDropDown = function(args) {

	var _this = this;

	if (args.column.values) {
		ComboBoxEditor.apply(_this, arguments);
	}
	else {
		// TODO: usar otro stored que traiga solo los usuarios de la hoja
		UserListDropDown.transaction.getUserList(function(data, status) {
			var keyValuePairs = [];
			for (var i = 0; i < data.length; i++) {
				keyValuePairs.push({
					key: data[i].username,
					value: data[i].user_id
				});
			};
			// cachear resultado?
			ComboBoxEditor.call(_this, args, keyValuePairs);
		});
	}

	this.isValueChanged = function() {
		return false;
	};

	this.serializeValue = function() {
		return null;
	};
};
UserListDropDown.transaction = null;

var TextFormatter = function(row, cell, value, columnDef, dataContext) {
	return urlToHTMLAnchor(value);
};

var urlRegexp = new RegExp("((?:http|https|ftp)://[\\w\\]\\[!\"#$%&'()*+,./:;<=>?@\\^_`{|}~-]+)", "gi");

var urlToHTMLAnchor = function(text) {
	text = text || "";
	return text.replace(urlRegexp, '<a href="$1" target="_blank">$1</a>');
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

var arrayRemoveItem = function(array, item) {
	for (var i = 0; i < array.length; i++) {
		if (array[i] == item) {
			array.splice(i, 1);
		}
	};
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
var WCGrid = function() {
	
	this.DataConverter = function() {

		var sortByOrderIndex = function(dataSet) {
			dataSet.sort(function(a, b) {
				return a.order_index - b.order_index;
			});
			return dataSet;
		};

		
		this.convertColumnData = function(data) {
			data = sortByOrderIndex(data);
			return data;

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
			formatter: TextFormatter,
			validator: null
		},
		"longText": {
			editor: TextMarkup
		},
		"boolean": {
			editor: Slick.Editors.Checkbox,
			formatter: Slick.Formatters.Checkmark,
			cssClass: "boolean-column"
		},
		"date": {
			editor: Slick.Editors.Date
		},
		"user": {
			// combobox: falta armar el control
			editor: UserListDropDown
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
		EditColumn: "edit-column",
		SetStyle: "set-style"
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
		}, {
			title: "Set style",
			command: MenuCommand.SetStyle
		}
	];

	var GridConfig = {
		autoEdit: false,
		enableAddRow: true,
		forceFitColumns: true,
		enableCellNavigation: true,
		enableColumnReorder: true,
		topPanelHeight: 300
	};

	var IdColumn = {
		id: "id",
		name: "ID",
		field: "id",
		width: 40,
		cssClass: "cell-selection",
		cannotTriggerInsert: true,
		resizable: false,
		selectable: false,
		focusable: false,
		order_index: 0
	};
		
	this.DataGrid = function(columns, rows, containerSelector, options) {
		
		var _event = new EventDispatcher(this);
		var _grid;
		var _headerMenuPlugin;
		var _options = {};

		var init = function() {
			copy(_options, GridConfig);
			copy(_options, options);
			settingColumns();
			addTheIdColumn();
			render();
		};

		var render = function() {
			_grid = new Slick.Grid(containerSelector, rows, columns, _options);
			_headerMenuPlugin = new Slick.Plugins.HeaderMenu({});
			_headerMenuPlugin.onCommand.subscribe(menuCommandHandler);
			_grid.registerPlugin(_headerMenuPlugin);
			_grid.onCellChange.subscribe(updateFieldValue);
			_grid.onAddNewRow.subscribe(createIssue);
			_grid.onHeaderDblClick.subscribe(editColumn);

			$("#inline-panel").appendTo(_grid.getTopPanel()).show();
		};

		var addTheIdColumn = function() {
			columns.unshift(IdColumn);
		};

		var editColumn = function() {
			alert("Not implemented");
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

		var getColumnCSSClassName = function(columnId) {
			return "field-" + columnId;
		};

		var setColumnStyle = function(columnId, style) {
			var className = getColumnCSSClassName(columnId);
			createCSSClass("." + className, style);
		};

		var setColumnCSSClass = function(column) {
			if (column.style) {
				setColumnStyle(column.field_id, column.style);
			}
			if (column.cssClass) {
				column.cssClass += " " + getColumnCSSClassName(column.field_id);
			}
			else {
				column.cssClass = getColumnCSSClassName(column.field_id);
			}
		};

		var setColumnWidth = function(column) {
			column.width = parseInt(column.width) || 250;
		};

		var setColumnResizable = function(column) {
			if (column.field_type == "boolean") {
				column.resizable = false;
			}
		};

		var settingColumn = function(column) {
			setColumnId(column);
			setColumnMenu(column);
			setColumnType(column);
			setColumnCSSClass(column);
			setColumnWidth(column);
			setColumnResizable(column);
		};

		var settingColumns = function() {
			for (var i = 0; i < columns.length; i++) {
				settingColumn(columns[i]);
			};
		};

		var menuCommandHandler = function(e, args) {
			_event.dispatchEvent("headerMenuCommand", args.command, parseInt(args.column.order_index), args.column.id);
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

		var getColumnIndex = function(columnId) {
			var index = -1;
			for (var i = 0; i < columns.length; i++) {
				if (columns[i].id == columnId) {
					index = i;
				}
			};
			return index;
		};

		this.addRow = function(row) {
			rows.push(row);
			_grid.invalidateRows([rows.length - 1]);
			_grid.updateRowCount();
			_grid.render();
		};

		this.addColumn = function(column, orderIndex) {
			// TODO: estar atento del ordenamiento de columnas. Testear!
			reorderColumns(orderIndex);
			settingColumn(column);
			columns.splice(orderIndex, 0, column);
			render();
			//_grid.setColumns(columns);
		};

		this.deleteColumn = function(columnId) {
			columns.splice(getColumnIndex(columnId), 1);
			_grid.setColumns(columns);
		};

		this.canDeleteColumn = function() {
			return columns.length > 2;
		};

		this.setColumnStyle = setColumnStyle;

		this.showTopPanel = function() {
			//_grid.showTopPanel();
		};

		this.hideTopPanel = function() {
			//_grid.hideTopPanel();
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

	this.getList = function(callback) {
		performTransaction("get_list", null, function(data, status) {
			dispatchEvent("getList", callback, data, status);
		});
	};

	this.getListUser = function(listId, callback) {
		performTransaction("get_user_by_list_id", { list_id: listId }, function(data, status) {
			dispatchEvent("getListUser", callback, data, status);
		});
	};

	this.getUserList = function(callback) {
		performTransaction("get_user_list", null, function(data, status) {
			dispatchEvent("getUserList", callback, data, status);
		});
	};

	this.getPermissionType = function(callback) {
		performTransaction("get_permission_type", null, function(data, status) {
			dispatchEvent("getPermissionType", callback, data, status);
		});
	};

	this.getListPermission = function(listId, callback) {
		performTransaction("get_list_permission", { list_id: listId }, function(data, status) {
			dispatchEvent("getListPermission", callback, data, status);
		});
	};

	this.getListData = function(listId, callback) {
		var synchronizer = new Synchronizer(["column", "row"]);
		synchronizer.notify(function(data, status) {
			dispatchEvent("getListData", callback, data, status);
		});
		performTransaction("get_field_by_list_id", { list_id: listId }, function(data, status) {
			synchronizer.commit("column", data, status);
		});
		performTransaction("get_field_value_by_list_id", { list_id: listId }, function(data, status) {
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

	this.insertField = function(listId, fieldTypeId, orderIndex, name, values, defaultValues, callback) {
		performTransaction("insert_field_with_order_index", {
			list_id: listId,
			field_type_id: fieldTypeId,
			order_index: orderIndex,
			name: name,
			values: values,
			default_value: defaultValues
		}, function(data, status) {
			dispatchEvent("insertField", callback, data, status);
		});
	};

	this.deleteField = function(fieldId, callback) {
		performTransaction("delete_field", { field_id: fieldId }, function(data, status) {
			dispatchEvent("deleteField", callback, data, status);
		});
	};

	this.updateFieldStyle = function(fieldId, style, callback) {
		performTransaction("update_field_style", {
			field_id: fieldId,
			style: style
		}, function(data, status) {
			dispatchEvent("updateFieldStyle", callback, data, status);
		});
	};

	this.insertList = function(name, description, callback) {
		performTransaction("insert_list_with_user", {
			name: name,
			description: description
		}, function(data, status) {
			dispatchEvent("insertList", callback, data, status);
		});
	};

	this.insertListUser = function(listId, email, permissionTypeId, callback) {
		performTransaction("insert_user_list_by_user_email", {
			list_id: listId,
			email: email,
			permission_type_id: permissionTypeId
		}, function(data, status) {
			dispatchEvent("insertListUser", callback, data, status);
		});
	};

	this.updateFieldValue = function(fieldValueId, listId, fieldId, userId, value, issueId, callback) {
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
				list_id: listId,
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

var Permission = {
	Administrator: 1,
	Editor: 2,
	Watcher: 3
};

var ApplicationUI = function() {
	
	var _dataSource = new JSONPDataSource();
	var _transaction = new TransactionManager(_dataSource);
	var _converter = new WCGrid.DataConverter();
	var _currentPermission = Permission.Watcher;
	var _currentList = null;
	var _currentDataGrid = null;

	var _columnDialog = new ColumnDialog();

	UserListDropDown.transaction = new TransactionManager(new JSONPDataSource());

	var init = function() {
		_transaction.getPermissionType(function(data, status) {
			for (var i = 0; i < data.length; i++) {
				$("#permission-list").append(new Option(data[i].name, data[i].permission_type_id));
			};
		});

		$("#add-user-button").on("click", function() {
			var email = $("#user-email").val();
			if (_currentList && email) {
				_transaction.insertListUser(_currentList, email, $("#permission-list").val(), function(data, status) {
					showListUser(_currentList);
				});
			}
		});
	};

	_dataSource.setOnError(function() {
		alert("Request error!");
	});

	var addProject = function(id, name) {
		$("#project").append(new Option(name, id));
	};

	var addList = function(id, name) {
		new Tab(id, name);
	};

	var updateFieldValue = function(issueId, fieldId, fieldValueId, userId, value) {
		_transaction.updateFieldValue(fieldValueId, _currentList, fieldId, userId, value, issueId);
	};

	var createIssue = function(orderIndex, fieldId, userId, value) {
		_transaction.insertFieldValue(orderIndex, fieldId, userId, value, function(data, status) {
			var row = _converter.convertRowData(data);
			_currentDataGrid.addRow(row[0]);
		});
	};

	var createColumn = function(orderIndex, formData) {
		_transaction.insertField(_currentList, formData.type, orderIndex, formData.name, formData.values, formData.defaultValue, function(data, status) {
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

	var deleteColumn = function(orderIndex, fieldId) {
		if (_currentDataGrid.canDeleteColumn()) {
			if (confirm("Will lose all data associated with this column. Are you sure you want to proceed?")) {
				_transaction.deleteField(fieldId, function(data, status) {
					_currentDataGrid.deleteColumn(fieldId);
				});
			}
		}
		else {
			alert("A list must have at least one column");
		}
	};

	var setColumnStyle = function(fieldId) {
		var style = prompt("Insert style comma-separated\nExample: font-weight: bold;");
		if (style) {
			_transaction.updateFieldStyle(fieldId, style, function(data, status) {
				
			});
			_currentDataGrid.setColumnStyle(fieldId, style);
		}
	};

	var headerMenuHandler = function(command, orderIndex, fieldId) {
		if (_currentPermission == Permission.Watcher) {
			alert("You have not permission puto!");
			return;
		}
		switch(command) {
			case WCGrid.MenuCommand.InsertToLeft:
				showColumnCreationForm(orderIndex);
				break;
			case WCGrid.MenuCommand.InsertToRight:
				showColumnCreationForm(orderIndex + 1);
				break;
			case WCGrid.MenuCommand.DeleteColumn:
				deleteColumn(orderIndex, fieldId);
				break;
			case WCGrid.MenuCommand.EditColumn:
				alert("Edit command is not implemented");
				break;
			case WCGrid.MenuCommand.SetStyle:
				setColumnStyle(fieldId);
				break;
			default:
				// ???
				break;
		}
	};

	var showListUser = function(listId) {
		var html = "<ul>";
		_transaction.getListUser(listId, function(data, status) {
			for (var i = 0; i < data.length; i++) {
				var user = "<li>" + (data[i].username || (data[i].email + " (unconfirmed account)")) + "</li>";
				$("#user-list")[0].innerHTML += user;
			};
		});
		$("#user-list")[0].innerHTML = html + "</ul>";
	};

	var isEditable = function(permission) {
		var editable = false;
		if (permission.permission_type_id == Permission.Editor ||
			permission.permission_type_id == Permission.Administrator) {
			editable = true;
		}
		else {
			alert("You have not permission for edit this list. It will be shown as Read-Only");
		}
		return editable;
	};

	this.loadListData = function(listId) {
		var sync = new Synchronizer(["listData", "listPermission"]);
		sync.notify(function(result) {
			var columns = _converter.convertColumnData(result.listData.column);
			var rows = _converter.convertRowData(result.listData.row);
			var options = { editable: isEditable(result.listPermission[0]) };
			_currentDataGrid = new WCGrid.DataGrid(columns, rows, "#data-grid", options);
			_currentDataGrid.addEventListener("headerMenuCommand", headerMenuHandler);
			_currentDataGrid.addEventListener("updateCell", updateFieldValue);
			_currentDataGrid.addEventListener("newRow", createIssue);
			_currentList = listId;
		});
		_transaction.getListPermission(listId, function(data, status) {
			_currentPermission = data[0].permission_type_id;
			sync.commit("listPermission", data);
		});
		_transaction.getListData(listId, function(data, status) {
			sync.commit("listData", data);
		});
		showListUser(listId);
	};

	this.loadList = function() {
		_transaction.getList(function(data, status) {
			for (var i = 0; i < data.length; i++) {
				var tag = data[i].tag_name? " <span style='color: #eaa748'>[" + data[i].tag_name + "]</span>": "";
				addList(data[i].list_id, data[i].name + tag);
			}
		});
	};

	this.createList = function(name) {
		_transaction.insertList(name, "descripcion default", function(data, status) {
			addList(data[0].list_id, data[0].name);
		});
	};

	this.addEventListener = function(eventName, callback) {
		_transaction.addEventListener(eventName, callback);
	};

	init();
};

var ColumnDialog = function() {

	var _onSubmit = null;

	var createColumn = function() {
		var formData = {};
		formData.name = $("#column-name").val();
		formData.type = $(".tmp-column-creator select").val();
		formData.values = $(".tmp-column-creator textarea").val().replace(/\n/g, ",");
		formData.defaultValue = $("#def-value").val();
		if (formData.name && formData.type) {
			if (_onSubmit) {
				_onSubmit(formData);
			}
			$(".tmp-column-creator").css("display", "none");
		}
		else {
			alert("Completá los dato loco!\n(name y value son obligatorios)");
		}
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

var Tab = function(listId, title) {
	var tabs = document.getElementById("tabs");
	var tab = document.createElement("li");
	tab.innerHTML = title;
	tab.style.cursor = "pointer";
	tab.onclick = function() {
		appUI.loadListData(listId);
	};
	tabs.appendChild(tab);
};

var selectProject = function() {
	var tabs = document.getElementById("tabs");
	tabs.innerHTML = "";
	selectedProject = $("#project").val();

	appUI.selectProject(selectedProject);
	appUI.loadProjectLists();
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

var createList = function(obj) {
	var listInput = document.getElementById("list-name");
	if (listInput.value) {
		appUI.addEventListener("insertList", function() {
			obj.removeAttribute("disabled");
		});
		appUI.createList(listInput.value);

		listInput.value = "";
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
	WCGrid = new WCGrid();

	appUI = new ApplicationUI();
	appUI.loadList();

	
	//columnDialog = new ColumnDialog();
});
