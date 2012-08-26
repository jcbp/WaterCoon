/*
*
*  createCSSClass()
*  http://www.happycode.info/
*
*/
function createCSSClass(selector, style) {

	var docStyleSheets = document.styleSheets;
	var head = document.getElementsByTagName("head");

	if (!docStyleSheets) {
		return;
	}
 
	if (head.length == 0) {
		return;
	}
 
	var stylesheet;
	var mediaType;
	if (docStyleSheets.length > 0) {
		for (i = 0; i < docStyleSheets.length; i++) {
			if (docStyleSheets[i].disabled) {
				continue;
			}
			var media = docStyleSheets[i].media;
			mediaType = typeof media;
 
			if (mediaType == "string") {
				if (media == "" || (media.indexOf("screen") != -1)) {
					styleSheet = docStyleSheets[i];
				}
			} else if (mediaType == "object") {
				if (media.mediaText == "" || (media.mediaText.indexOf("screen") != -1)) {
					styleSheet = docStyleSheets[i];
				}
			}
 
			if (typeof styleSheet != "undefined") {
				break;
			}
		}
	}
 
	if (typeof styleSheet == "undefined") {
		var styleSheetElement = document.createElement("style");
		styleSheetElement.type = "text/css";
 
		head[0].appendChild(styleSheetElement);
 
		for (i = 0; i < docStyleSheets.length; i++) {
			if (docStyleSheets[i].disabled) {
				continue;
			}
			styleSheet = docStyleSheets[i];
		}
 
		var media = styleSheet.media;
		mediaType = typeof media;
	}
 
	if (mediaType == "string") {
		for (i = 0; i < styleSheet.rules.length; i++) {
			if (styleSheet.rules[i].selectorText.toLowerCase() == selector.toLowerCase()) {
				styleSheet.rules[i].style.cssText = style;
				return;
			}
		}
 
		styleSheet.addRule(selector, style);
	} else if (mediaType == "object") {
		for (i = 0; i < styleSheet.cssRules.length; i++) {
			if (styleSheet.cssRules[i].selectorText.toLowerCase() == selector.toLowerCase()) {
				styleSheet.cssRules[i].style.cssText = style;
				return;
			}
		}
 
		styleSheet.insertRule(selector + "{" + style + "}", 0);
	}
};
