<cffunction name="getAPIDefinition" access="remote" output="true" returntype="array" description="Acquire a list of API definitions and what they are set to.">
	<cfset return_array = ArrayNew(1) />
	
	<!--- :: API Entry 1 :: --->
	<cfset api_object = StructNew() />
	<cfset api_object.name = "api_one" />
	<cfset api_object.component = "cfcs.path.component" />
	<cfset api_object.url = "https://www.myserver.com/my_api/api_one/component.cfc?WSDL" />
	<cfset api_object.method = "invokeCfcMethod" />
	<cfset ArrayAppend(return_array, api_object) />
	
	<cfreturn return_array />
</cffunction>

<cffunction name="executeAPICall" access="remote" output="yes" returntype="any" description="Logs the API Request if logging is set, then upon sucess, executes an API Call and returns the result (any type)." hint="Accepts up to 20 parameters.">
	<cfargument name="api_called" type="string" required="yes">
	<cfargument name="api_log" type="boolean" required="yes" default="true">
	<cfargument name="api_application" type="string" required="yes">
	<cfargument name="api_user" type="string" required="yes">
	<cfargument name="parameter_1" type="any" required="no" default="">
	<cfargument name="parameter_2" type="any" required="no" default="">
	<cfargument name="parameter_3" type="any" required="no" default="">
	<cfargument name="parameter_4" type="any" required="no" default="">
	<cfargument name="parameter_5" type="any" required="no" default="">
	<cfargument name="parameter_6" type="any" required="no" default="">
	<cfargument name="parameter_7" type="any" required="no" default="">
	<cfargument name="parameter_8" type="any" required="no" default="">
	<cfargument name="parameter_9" type="any" required="no" default="">
	<cfargument name="parameter_10" type="any" required="no" default="">
	<cfargument name="parameter_11" type="any" required="no" default="">
	<cfargument name="parameter_12" type="any" required="no" default="">
	<cfargument name="parameter_13" type="any" required="no" default="">
	<cfargument name="parameter_14" type="any" required="no" default="">
	<cfargument name="parameter_15" type="any" required="no" default="">
	<cfargument name="parameter_16" type="any" required="no" default="">
	<cfargument name="parameter_17" type="any" required="no" default="">
	<cfargument name="parameter_18" type="any" required="no" default="">
	<cfargument name="parameter_19" type="any" required="no" default="">
	<cfargument name="parameter_20" type="any" required="no" default="">
	
	<cfset return_object = StructNew() />

	<cfinvoke method="getAPIDefinition" returnvariable="api_settings" component="cfapi.config.settings" />
	
	<cfset found_boolean = false />
	<cfset found_struct = StructNew() />
	<cfloop array="#api_settings#" item="api_object">
		<cfif api_called EQ api_object.name>
			<cfset found_struct.component = api_object.component />
			<cfset found_struct.url = api_object.url />
			<cfset found_struct.method = api_object.method />
			<cfset found_boolean = true />
		<cfelseif api_object.name eq "api_log">
			<cfset api_log_url_string = api_object.url />
			<cfset api_log_method_string = api_object.method />
		<cfelseif api_object.name eq "api_metadata">
			<cfset api_metadata_component_string = api_object.component />
			<cfset api_metadata_url_string = api_object.url />
			<cfset api_metadata_method_string = api_object.method />
		</cfif>
	</cfloop>

	<cfif found_boolean EQ true and isDefined('api_log_url_string') and isDefined('api_metadata_url_string') and isDefined('api_metadata_component_string')>
	
		<cfset temp_object.api = ArrayNew(1) />
		
		<cfset temp_struct = StructNew() />
		<cfset temp_struct.api_called = api_called />
		<cfset temp_struct.api_application = api_application />
		<cfset temp_struct.api_user = api_user />
		<cfset temp_struct.api_user_ip = CGI.remote_addr />
		<cfset temp_struct.api_timestamp = Now() />
		<cfset temp_struct.api_method = found_struct.method />
		<cfset temp_struct.component = found_struct.component />
		<cfset temp_struct.api_url = found_struct.url />
		<cfset ArrayAppend(temp_object.api, temp_struct) />
		
		<cfset temp_object.parameters = ArrayNew(1) />
		
		<!--- run these calls through component, as it is faster. --->
		<cfif temp_object.api[1].api_application eq "scheduler">
			<cfinvoke method="#api_metadata_method_string#" returnvariable="apiMetadata" component="#api_metadata_component_string#">
				<cfinvokeargument name="component_path" value="#found_struct.component#" />
			</cfinvoke>
		<cfelse>
			<cfinvoke method="#api_metadata_method_string#" returnvariable="apiMetadata" webservice="#api_metadata_url_string#">
				<cfinvokeargument name="component_path" value="#found_struct.component#" />
			</cfinvoke>
		</cfif>
		
		<cfset expected_parameter_array = ArrayNew(1) />
		
		<cfif isDefined('apiMetadata')>
			<cfif isDefined('apiMetadata.functions') and ArrayLen(apiMetadata.functions) GT 0>
				<cfloop array="#apiMetadata.functions#" index="api_function">
					<cfif isDefined('api_function.name') and api_function.name eq found_struct.method>
						<cfif isDefined('api_function.parameters') and ArrayLen(api_function.parameters) GT 0>
							<cfloop array="#api_function.parameters#" index="parameter">
								<cfset ArrayAppend(expected_parameter_array, parameter.name) />
							</cfloop>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfset array_counter_integer = 0 />
		<cfloop array="#expected_parameter_array#" index="expected_parameter">
			<cfset array_counter_integer += 1 />
			<cfset current_parameter = arguments["parameter_" & array_counter_integer] />
			<cfset current_parameter_struct = IsStruct(current_parameter)>
			<cfset current_parameter_array = IsArray(current_parameter)>
			<cfif current_parameter_struct or current_parameter_array>
				<cfset new_argument_struct = StructNew() />
				<cfset new_argument_struct[expected_parameter] = arguments["parameter_" & array_counter_integer] />
				<cfset ArrayAppend(temp_object.parameters, new_argument_struct) />
			<cfelse>
				<cfif current_parameter neq "">
					<cfset new_argument_struct = StructNew() />
					<cfset new_argument_struct[expected_parameter] = arguments["parameter_" & array_counter_integer] />
					<cfset ArrayAppend(temp_object.parameters, new_argument_struct) />
				</cfif>
			</cfif>
		</cfloop>

		<cfif ArrayLen(expected_parameter_array) EQ ArrayLen(temp_object.parameters)>
			<cfset is_logged = false />
			<cfif api_log eq true>
				<cfinvoke method="#api_log_method_string#" returnvariable="is_logged" webservice="#api_log_url_string#">
					<cfinvokeargument name="api" value="#temp_object.api[1]#" />
					<cfinvokeargument name="parameters" value="#temp_object.parameters#" />
				</cfinvoke>
			<cfelse>
				<cfset is_logged = true />
			</cfif>
			<cfif is_logged eq true>
				<!--- run these calls through component, as it is faster. --->
				<cfif temp_object.api[1].api_application eq "scheduler">
					<cfinvoke method="#temp_object.api[1].api_method#" returnvariable="return_object" component="#temp_object.api[1].component#">
						<cfloop array="#temp_object.parameters#" index="parameter">
							<cfloop collection="#parameter#" item="key">
								<cfinvokeargument name="#key#" value="#parameter[key]#" />
							</cfloop>
						</cfloop>
					</cfinvoke>
				<cfelse>
					<cfinvoke method="#temp_object.api[1].api_method#" returnvariable="return_object" webservice="#temp_object.api[1].api_url#">
						<cfloop array="#temp_object.parameters#" index="parameter">
							<cfloop collection="#parameter#" item="key">
								<cfinvokeargument name="#key#" value="#parameter[key]#" />
							</cfloop>
						</cfloop>
					</cfinvoke>
				</cfif>
				<cfset temp_object.return = return_object />
			<cfelse>
				<cfset temp_object.return = "ERROR: The API could not execute because it could not log the attempted call." />
			</cfif>
		</cfif>
		
	<cfelse>
		<cfset return_object = "ERROR: There was no API definition for this call." />
		<cfset return_object.ERROR = "ERROR: There was no API definition for this call." />
	</cfif>
	
	<!--- to debug, return the object {temp_object} instead. --->
	<cfreturn return_object />
</cffunction>