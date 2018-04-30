<head>
	<title>API Mapping</title>
	<cfoutput>
		<cfset templatePath = "cfapi/assets" />
		<link rel="shortcut icon" href="/#EncodeForHTML(templatePath)#/img/favicon_map.ico" type="image/x-icon" />
		<script src="/#EncodeForHTML(templatePath)#/js/jquery.min.js"></script>
		<script src="/#EncodeForHTML(templatePath)#/js/jquery-ui.min.js"></script>
		<script src="/#EncodeForHTML(templatePath)#/js/include.js"></script>
		<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/include.css" />
		<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/jquery-ui.theme.min.css" />
	</cfoutput>
</head>

<cfinvoke component="cfapi.config.settings" method="getAPIDefinition" returnvariable="api_definition_array" />

<cfoutput>
	<h3 class="headerSimple" style="font-size: 20px;"><img src="/#EncodeForHTML(templatePath)#/img/favicon_map.ico" /> API Mapping</h3>
	<cfloop array="#api_definition_array#" index="api_definition">
	
		<cfinvoke method="getMetadataByAPI" returnvariable="apiMetadata" component="cfapi.component.api_log">
			<cfinvokeargument name="component_path" value="#api_definition.component#" />
		</cfinvoke>
		
		<cfset expected_parameter_array = ArrayNew(1) />
		
		<cfif isDefined('apiMetadata')>
			<cfif isDefined('apiMetadata.functions') and ArrayLen(apiMetadata.functions) GT 0>
				<cfloop array="#apiMetadata.functions#" index="api_function">
					<cfif isDefined('api_function.name') and api_function.name eq api_definition.method>
						<cfif isDefined('api_function.parameters') and ArrayLen(api_function.parameters) GT 0>
							<cfloop array="#api_function.parameters#" index="parameter">
								<cfset ArrayAppend(expected_parameter_array, parameter.name) />
							</cfloop>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<span class="color-default">#api_definition.name# = </span>
		<span class="color-one-simple">#api_definition.component#.</span><span class="color-two">#api_definition.method#{</span><span class="color-default">#ArrayToList(expected_parameter_array, ', ')#</span><span class="color-two">}</span>
		<br />
	</cfloop>
</cfoutput>