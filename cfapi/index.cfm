<html>

	<head>
		<title>API</title>
		<cfoutput>
			<cfset templatePath = "cfapi/assets" />
			<link rel="shortcut icon" href="/#EncodeForHTML(templatePath)#/img/favicon.ico" type="image/x-icon" />
			<script src="/#EncodeForHTML(templatePath)#/js/jquery.min.js"></script>
			<script src="/#EncodeForHTML(templatePath)#/js/jquery-ui.min.js"></script>
			<script src="/#EncodeForHTML(templatePath)#/js/include.js"></script>
			<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/include.css" />
			<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/jquery-ui.theme.min.css" />
		</cfoutput>
		
		<script>
			function loadAPIMethod( api_path, component_row ) {
				$("html, body").animate({ scrollTop: 0 }, "slow");
				$('#api_method_div').html("<img src='/assets/img/progress.gif'>");
				
				cleanCssHighlight("component", component_row);
				
				$.get("controller.cfm?api_path=" + api_path,
					function (data, status) {
						$('#api_method_div').html(data);
					}
				)
				loadAPIFunction( api_path );
			}
			function loadAPIFunction( api_path, method, method_row ) {
				$('#api_function_div').html("<img src='/assets/img/progress.gif'>");
				
				cleanCssHighlight("method", method_row);

				if(method !== undefined) {
					$.get("controller.cfm?api_path=" + api_path + "&method=" + method,
						function (data, status) {
							$('#api_function_div').html(data);
						}
					)
				} else {
					$('#api_function_div').html('');
				}
			}
			function loadAPIQuery () {
				var path = $('#api_component').val();
				path = '/' + path.replace(/\./g, '/') + '.cfc';
				var method = $('#api_method').val();
				var parameter = {};
				parameter["method"] = method;
				parameter["refreshwsdl"] = $('input[name=refreshwsdl]:checked').val();
				
				$('#parameter_div input').each(function(){
					var $element = $(this);
					var element_id = $element.prop('id').toString().trim();
					var element_name = $element.prop('name').toString().trim();
					var element_type = $element.prop('type').toString().trim();
					var parameter_name = element_name.replace(/(?:parameter)_{1}([A-z]{1,})_{1}\d{1,}_{1}input/g, '$1');
					if(element_type !== "radio") {
						$(this).val($(this).val().toString().trim());
						parameter[parameter_name] = $(this).val();
					
					} else {
						var element_checked = $element.prop('checked').toString().trim();
						if(element_checked === "true" || element_checked === "yes" || element_checked === "1")
							parameter[parameter_name] = $('input[name=' + element_name + ']:checked').val();
					}
				});
				
				if(validateAPIParameters()) {
					$('#result_div').html("<img src='/assets/img/progress.gif'>");
					$.ajax ({
						url: path,
						data: parameter,
						success: function(response) {
							var return_html = "";
							try {
								var is_json = JSON.parse(response);
							} catch(e) {
								var is_json = false;
							}
							
							return_html = return_html + "<span class='headerSimple'>Response {</span><br />";

							if(is_json !== false) {
								if(is_json.constructor === Array) {
									$.each(is_json, function(index) {
										var inner_json = is_json[index];
										return_html = return_html + "<span class='color-five'>[" + index + "]: {</span><br />";
										$.each(inner_json, function(key, value) {
											return_html = return_html + "<span class='color-default'>" + key + ":</span> ";
											//RECURSION is a cool idea, but probably a waste of time...
											//if(value !== null && typeof value === 'object') {
											//} else {
											return_html = return_html + "<span class='color-one-simple'>" + value + "</span><br />";
											//}
										});
										return_html = return_html + "<span class='color-five'>}</span><br />";
									});
								} else {
									$.each(is_json, function(key, value) {
										return_html = return_html + "<span class='color-default'>" + key + ":</span> ";
										return_html = return_html + "<span class='color-one-simple'>" + value + "</span><br />";
									});
								}
							} else {
								if(response.search("cfdump") > 0) {
									response = response.replace(/\<wddxPacket.*\<\/wddxPacket\>/g, "").trim();
								} else if (response.search("<number>") > 0 ){
									response = response.replace(/\<wddxPacket.*\<data\>/g, "").
														replace(/\<\/data\>.*<\/wddxPacket\>/g, "").
														replace(/<\/?number>/g, "");
									response = "<span class='color-default'>" + response + "</span><br />";
								} else if (response.search("<array")> 0) {
									response = response.replace(/\<wddxPacket.*\<data\>/g, "").
														replace(/\<\/array\>.*<\/wddxPacket\>/g, "");
									var object_length = response.match(/\d{1,}/)[0];
									if(!isNaN(object_length)) {
										response = response.replace(/\<array length=\'\d{1,}\'\>/, "");
										response = response.match(/(?=<string>).*/)[0];
										response = response.replace(/<\/string>/g, "</span><br />");

										for (i = 1; i <= object_length; i++) { 
											response = response.replace(/<string>/, "<span class='color-five'>[" + i + "]</span><span class='color-default'> ");
										}
									}
								} else if (response.search("<boolean") > 0) {
									response = response.replace(/\<wddxPacket.*\<data\>/, "").
														replace(/\<\/data>.*<\/wddxPacket\>/, "").
														replace(/\<boolean value=\'/g, "<span class='color-default'>").
														replace(/\'\/\>/g, "</span><br />");
								} else {
									response = response.replace(/\<wddxPacket.*\<data\>/, "").
														replace(/\<\/data>.*<\/wddxPacket\>/, "").
														replace(/\<string\>/g, "<span class='color-default'>").
														replace(/\<\/string\>/g, "</span><br />");
								}
								if(response.length === 0) {
									return_html = return_html + "<span class='color-default'>The response was truncated because it is a complex datatype: Set debug to true for complete response.</span><br />";
								} else {
									return_html = return_html + response;
								}
							}
							return_html = return_html + "<span class='headerSimple'>}</span>";
							$('#result_div').html(return_html);
					}});
				}
				
				$('button').blur();
			}
			function validateAPIParameters() {
				var string_array = ["any","string","guid","uuid","xml"];
				var numeric_array = ["numeric"];
				var boolean_array = ["boolean","binary"];
				var date_array = ["date","timestamp"];
				var errorHeader = "Invalid Parameters:\n"
				var errorMessage = "";
				
				$('#parameter_div input').each(function(){
					var $element = $(this);
					var field_id = $element.prop('id').toString().trim();
					var field_name = $element.data('name').toString().trim();
					var field_required = $element.data('required').toString().trim();
					var field_type = $element.data('type').toString().trim();
					var field_value = $element.val();
					var multifield_value = $('#' + field_id).val();
					
					if(field_required === "true" && field_value === "") {
						errorMessage = errorMessage + field_name + " is required!\n";
					} else {
					
						if(string_array.indexOf(field_type) > -1) {
							if(typeof(field_value) !== "string") {
								errorMessage = errorMessage + field_name + " is not a valid " + field_type + ".\n";
							}
						} else if (numeric_array.indexOf(field_type) > -1) {
							if(typeof(field_value) !== "number") {
								errorMessage = errorMessage + field_name + " is not a valid " + field_type + ".\n";
							}
						} else if (boolean_array.indexOf(field_type) > -1) {
							if(multifield_value !== "true" && multifield_value !== "false" && multifield_value !== "1" && multifield_value !== "0") {
								errorMessage = errorMessage + field_name + " is not a valid " + field_type + ".\n";
							}
						} else if (date_array.indexOf(field_type) > -1) {
							if(field_value.search(/\d{1,2}\/{1}\d{1,2}\/{1}\d{4}$/) === -1) {
								errorMessage = errorMessage + field_name + " is not a valid " + field_type + ".\n";
							}
						}
					}
				});
				if(errorMessage.length > 0) {
					errorMessage = errorHeader + errorMessage;
					alert(errorMessage);
					return false;
				}
				return true;
			}
			
			function loadAPIWrapper() {
				var path = $('#api_component').val();
				var method = $('#api_method').val();
				var url = "generate_wrapper.cfm";
				var type = $('#wrapper_type').val();
				var dump = $('#wrapper_dump').val();
				var parameter = {};
				parameter["path"] = path;
				parameter["method"] = method;
				parameter["type"] = type;
				parameter["dump"] = dump;
				
				$('#result_div').html("<img src='/assets/img/progress.gif'>");
				
				$.ajax ({
						url: url,
						data: parameter,
						success: function(response) {
							$('#result_div').html(response);
						}
				});
			}
			
			function toggleScope() {
				var type = $('#wrapper_type').val();
				if(type === "webservice") {
					$('#wrapper_type').val("component");
				} else {
					$('#wrapper_type').val("webservice");
				}
				loadAPIWrapper();
			}
			
			function toggleDump() {
				var type = $('#wrapper_dump').val();
				if(type === "true") {
					$('#wrapper_dump').val("false");
				} else {
					$('#wrapper_dump').val("true");
				}
				loadAPIWrapper();
			}
			
		</script>
	
	</head>
	
	<body>
		<cfdirectory name="apiComponents" action="list" directory="E:\inetpub\wwwroot\cfapi\" recurse="yes" filter="*.cfc" />

		<cfset currentProject = "" />
		<cfoutput>
			<div id="wrapper" class="unselectable">
				<div id="sub-menu">
					<div class="small-column">
							<span class="color-default largefont pointer" onClick="window.location.href='.'"><img src="/#EncodeForHTML(templatePath)#/img/favicon.ico" /> API</span>
					</div>
					<div class="small-column">
						&nbsp;
					</div>
					<div class="big-column">
						<span style="float:right; " class="color-one">
							<span onClick="window.location.href='/cfapi/documentation/api_mapping.cfm'"><img src="/#EncodeForHTML(templatePath)#/img/favicon_map.ico" /> Mapping</span>
							&nbsp;
							<span onClick="window.location.href='/cfapi/documentation/api_statistics.cfm'"><img src="/#EncodeForHTML(templatePath)#/img/favicon_statistics.ico" /> Statistics</span>
						</span>
					</div>
				</div>
			</div>
		</cfoutput> 
		<div id="wrapper" class="unselectable">
				<div id="sub-menu">
					<div class="small-column">
						<cfset component_row = 1 />
						<div id="component_div">
							<cfoutput query="apiComponents">
								<cfset cfcPath = directory & "\" & name />
								<cfset projectName = Reverse(Mid(Reverse(directory), 1, Find("\", Reverse(directory), 1)-1)) />
								<cfif projectName NEQ currentProject>
									<cfset currentProject = projectName />
									<br />
									<span id="container_#EncodeForHTMLAttribute(component_row)#_span" class="header">
										#EncodeForHTML(Ucase(projectName))#
									</span>
									<br /><br />
								</cfif>
								<cfset cfcPath = directory & "\" & name/>
								<cfset cfcPath = ToBase64(Trim(Replace(Trim(Replace(Mid(cfcPath, Find("cfapi", cfcPath, 1), Len(cfcPath)), "\", ".", "ALL")), ".cfc", "", "ALL"))) />
								<span id="component_#component_row#_span" class="color-one pointer" onClick="loadAPIMethod('#EncodeForJavascript(cfcPath)#', '#EncodeForJavascript(component_row)#')" title="\\yourserver\wwwroot\cfapi\#EncodeForHTML(Lcase(projectName))#\#Lcase(EncodeForHTML(name))#">#EncodeForHTML(name)#</span>
								<br />
								<cfset component_row += 1 />
							</cfoutput>
						</div>
					</div>
				<div id="api_method_div" class="small-column"></div>
				<div id="api_function_div" class="big-column"></div>
			</div>
		</div>
	</body>
</html>