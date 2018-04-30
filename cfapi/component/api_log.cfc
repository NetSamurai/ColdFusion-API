<cfcomponent>
	<cffunction name="logAPIUse" access="remote" output="yes" returntype="boolean" description="Creates a row in the API_Log table in the global schema then returns the result of the transaction as a boolean." hint="Not implemented yet.">
		<cfargument name="api" type="struct" required="yes">
		<cfargument name="parameters" type="array" required="yes">
		
		<cfset ran_boolean = false />
		
		<cftry>
			<cfinvoke method="convertArrayIntoJson" returnvariable="returned_parameters_json" component="cfapi.component.api_log">
				<cfinvokeargument name="parameters" value="#parameters#">
			</cfinvoke>
			
			<cfoutput>
			<cfset json_string = #SerializeJSON(returned_parameters_json)# />
			</cfoutput>
			
			<cfquery name="addAPILogEntry" datasource="yourdatasource1">
			insert	into	yourdbuser1.api_log
			(
				time_stamp,
				api_called,
				api_method_called,
				calling_application,
				calling_user_id,
				calling_user_ip,
				calling_parameters
			)
			values
			(
				sysdate,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#api.api_called#" />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#api.api_method#" />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#api.api_application#" />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#api.api_user#" />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#api.api_user_ip#" />,
				<cfqueryparam cfsqltype="cf_sql_clob" value="#json_string#" />
			)
			</cfquery>
			
			<cfset ran_boolean = true />
			
			<cfcatch type="any">
				<cfdump var = "#cfcatch#" />
				<cfset ran_boolean = false />
			</cfcatch>
		</cftry>
		
		<cfreturn ran_boolean />
	</cffunction>
	
	<cffunction name="convertArrayIntoJson" access="remote" output="yes" returntype="struct" description="Turns an array of structs into a Key:Pair Json Struct" hint="Used to store parameters that are given during an API call.">
		<cfargument name="parameters" type="array" />
		
		<cfset return_struct = StructNew() />
		
		<cfloop array="#parameters#" index="parameter">
			<cfloop collection="#parameter#" item="key">
				<cfset return_struct[#key#] = parameter[key] />
			</cfloop>
		</cfloop>

		<cfreturn return_struct />
	</cffunction>
	
	<cffunction name="getMetadataByAPI" access="remote" output="yes" returntype="any" returnformat="json" description="Returns the metadata about a CFC for use with the config and logging the API." hint="Don't implement this anywhere else.">
		<cfargument name="component_path" type="string" />
		
		<cftry>
			<cfset apiMetadata = StructNew() />
			<cfscript>
			apiSource = createObject("component", "#component_path#");
			apiMetadata = getMetaData(apiSource);
			</cfscript>
			<cfset StructDelete(apiMetadata, "skeleton") />

			<cfcatch type="Any">
				<cfdump var = '#cfcatch#' />
				<cfset apiMetadata = StructNew() />
				<cfset apiMetadata.ERROR = "There is no CFC by this name." />
			</cfcatch>
		</cftry>
		
		<cfreturn apiMetadata />
	</cffunction>
	
</cfcomponent>