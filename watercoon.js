
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
	// falta agregar en la DDBB
	"percent": {
		editor: Slick.Editors.PercentComplete
	}
};

var sortByOrderIndex = function(dataSet) {
	dataSet.sort(function(a, b) {
		return a.order_index - b.order_index;
	});
	return dataSet;
};

var buildColumnData = function(data) {
	data = sortByOrderIndex(data);
	var columns = [{
		id: "id",
		name: "#",
		field: "id",
		width: 40,
		cssClass: "cell-selection",
		cannotTriggerInsert: true,
		resizable: false,
		selectable: false,
		focusable: false
	}];
	for (var i=0; i<data.length; i++) {
		var row = data[i];
		var column = {
			id: row.field_id,
			name: row.name,
			field: row.field_id,
			default_value: row.default_value,
			values: row.values
		};
		copy(column, FieldType[row.field_type]);
		columns.push(column);
	}
	return columns;
};

var buildRowData = function(data) {
	
	var ret = [];
	var issues = {};
	
	for (var i=0; i<data.length; i++) {
		var issue;
		if (!issues[data[i].issue_id]) {
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


var DataGridManager = function(columnData, rowData, containerSelector) {
	
	var _options = {
		editable: true,
		autoEdit: false,
		enableAddRow: true,
		forceFitColumns: true,
		enableCellNavigation: true,
		enableColumnReorder: true
	};

	var _columns = buildColumnData(columnData);
	var _rows = buildRowData(rowData);
	var _grid = new Slick.Grid(containerSelector, _rows, _columns, _options);

	var updateFieldValue = function(e, args) {
		var fieldId = args.grid.getColumns()[args.cell].id;
		httpRequest({
			exec: "update_field_value",
			field_value_id: args.item.field_value_id[fieldId],
			user_id: null,
			value: args.item[fieldId]
		},
		function(resultSet, status) {
			
		});
	};

	var createIssue = function (e, args) {
		var issue = {};
		var columns = args.grid.getColumns();
		for (var i = 0; i < columns.length; i++) {
			issue[columns[i].id] = columns[i].default_value;
		};
		httpRequest({
			exec: "insert_issue_and_field_value",
			order_index: _rows.length + 1,
			field_id: args.column.id,
			user_id: null,
			value: args.item[args.column.id]
		},
		function(data, status) {
			var row = buildRowData(data);
			_rows.push(row[0]);
			//$.extend(issue, args.item);
			//rows.push(issue);
			_grid.invalidateRows([_rows.length - 1]);
			_grid.updateRowCount();
			_grid.render();
		});
	};

	_grid.onCellChange.subscribe(updateFieldValue);
	_grid.onAddNewRow.subscribe(createIssue);
};

var httpRequest = function(params, callback) {
	$.ajax({
		url: 'http://localhost/~charly/watercoon/data_layer.php',
		dataType: 'jsonp',
		type: "GET",
		jsonp: 'jsonp',
		timeout: 5000,
		data: params,
		success: callback,
		error: function() {
			alert("ERROR!!");
		}
	});
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

var synchronizer = new Synchronizer(["column", "row"]);
synchronizer.notify(function(data) {
	var dataGridMan = new DataGridManager(data.column, data.row, "#data-grid");
});

var loadSheet = function(sheetId) {
	httpRequest({exec: "get_field_by_sheet_id", sheet_id: sheetId}, function(data, status) {
		synchronizer.commit("column", data);
	});
	httpRequest({exec: "get_field_value_by_sheet_id", sheet_id: sheetId}, function(data, status) {
		synchronizer.commit("row", data);
	});
};



var Tab = function(sheetId, title) {
	var tabs = document.getElementById("tabs");
	var tab = document.createElement("li");
	tab.innerHTML = title;
	tab.style.cursor = "pointer";
	tab.onclick = function() {
		loadSheet(sheetId);
	};
	tabs.appendChild(tab);
};

var selectedProject = null;

var selectProject = function() {
	var tabs = document.getElementById("tabs");
	tabs.innerHTML = "";
	selectedProject = $("#project").val();
	httpRequest({
		project_id: selectedProject,
		exec: "get_sheet_by_project_id"
	},
	function(data, status) {
		for (i = 0; i < data.length; i++) {
			new Tab(data[i].sheet_id, data[i].name);
		}
	});
};

var createProject = function(obj) {
	var projectInput = document.getElementById("project-name");
	if (projectInput.value) {
		httpRequest({
			name: projectInput.value,
			exec: "insert_project_with_user"
		},
		function(data, status) {
			obj.removeAttribute("disabled");
			addProjectToList(data[0].name, data[0].project_id);
		});
		projectInput.value = "";
		obj.disabled = "disabled";
	}
};

var createSheet = function(obj) {
	var sheetInput = document.getElementById("sheet-name");
	if (sheetInput.value) {
		if (selectedProject) {
			httpRequest({
				project_id: selectedProject,
				name: sheetInput.value,
				exec: "insert_sheet_with_user"
			},
			function(data, status) {
				obj.removeAttribute("disabled");
				new Tab(data[0].sheet_id, data[0].name);
			});
			sheetInput.value = "";
			obj.disabled = "disabled";
		}
		else {
			alert("Debe seleccionar un proyecto");
		}
	}
};

var addProjectToList = function(name, id) {
	$("#project").append(new Option(name, id));
};

$(document).ready(function() {
	httpRequest({exec: "get_project_by_user_id"}, function(data, status) {
		for (i = 0; i < data.length; i++) {
			addProjectToList(data[i].name, data[i].project_id);
		}
	});
});
