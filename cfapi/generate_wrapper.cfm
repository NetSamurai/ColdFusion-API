<cfif isDefined('url.method') and url.method NEQ "" and isDefined('url.path') and url.path NEQ "">
	<cfinvoke method="getAPIDefinition" returnvariable="api" component="cfapi.config.settings" />
	<cfset thePath = trim(lcase(url.path)) />
	<cfset theMethod = trim(lcase(url.method)) />
	<cfset theType = trim(lcase(url.type)) />
	<cfset theDump = trim(lcase(url.dump)) />

	<cfset found_boolean = false />
	<cfloop array="#api#" index="api_entry">
		<cfif trim(lcase(api_entry.component)) EQ thePath>
			<cfif trim(lcase(api_entry.method)) EQ theMethod>
				<div id="output_div">
					<cfoutput>
						<cfset found_boolean = true />
						<cfset parameter_array = ArrayNew(1) />
						<!--- retrieve the parameters from the api source... --->
						<cfscript>
						apiSource = createObject("component", "#api_entry.component#");
						apiMetadata = getMetaData(apiSource);
						</cfscript>
						
						<cfset apiFunction = StructNew() />
						<cfif IsStruct(apiMetadata) && StructKeyExists(apiMetadata, "functions")>
							<cfset functionsAR = apiMetadata["functions"] />
							<cfloop array = "#functionsAR#" index="function">
								<cfif function["name"] EQ api_entry.method>
									<cfset apiFunction  = function />
								</cfif>
							</cfloop>
						</cfif>
						<cfif isDefined('apiFunction.returntype')>
							<cfset return_type = apiFunction.returntype />
						<cfelse>
							<cfset return_type = "object" />
						</cfif>
						
						<cfif isDefined('apiFunction.parameters')>
							<cfif IsArray(apiFunction.parameters) AND ArrayLen(apiFunction.parameters) GT 0>
								<cfloop array="#apiFunction.parameters#" index="parameter">
									<cfset parameter_struct = StructNew() />
									<cfif isDefined('parameter.default')>
										<cfset parameter_struct.hint = parameter.default />
									<cfelse>
										<cfif isDefined('parameter.hint')>
											<cfset parameter_struct.hint = parameter.hint />
										<cfelse>
											<cfset parameter_struct.hint = "" />
										</cfif>
									</cfif>
									<cfif isDefined('parameter.name')>
										<cfset parameter_struct.name = parameter.name />
									<cfelse>
										<cfset parameter_struct.name = "" />
									</cfif>
									<cfset ArrayAppend(parameter_array, parameter_struct) />
								</cfloop>
							</cfif>
						</cfif>
						
						<span class="color-one-simple">
							&lt;cfinvoke method="executeAPICall" returnvariable="returned_#return_type#" component="cfapi.config.settings"&gt;<br />
								&emsp;&emsp;&lt;cfinvokeargument name="api_called" value="#trim(lcase(api_entry.name))#" /&gt;<br />
								&emsp;&emsp;&lt;cfinvokeargument name="api_log" value="true" /&gt;<br />
								&emsp;&emsp;&lt;cfinvokeargument name="api_application" value="application_name" /&gt;<br />
								&emsp;&emsp;&lt;cfinvokeargument name="api_user" value="##session.auth.userid##" /&gt;<br />
								<cfif ArrayLen(parameter_array) GT 0>
									<cfset count_parameter_integer = 1 />
									<cfloop array="#parameter_array#" index="parameter">
										&emsp;&emsp;&lt;cfinvokeargument name="parameter_#count_parameter_integer#" value="#parameter.hint#" /&gt;<br />
										<cfset count_parameter_integer += 1 />
									</cfloop>
								</cfif>
								<cfif theDump EQ "true">
									<br /><br />&lt;cfdump var = "##returned_#return_type###" /&gt;
								</cfif>
							&lt;/cfinvoke&gt;<br />
							<br />

							
							
						</span>
						<br /><br />
						
					</cfoutput>
				</div>
				<button class="scriptButton" onclick="copyToClipboard('output_div');">Copy to Clipboard</button>
				<button class="gearButton" onclick="toggleScope();">Toggle Scope</button>
				<button class="wrenchButton" onclick="toggleDump();">Toggle Dump</button>
				<script>
					$(function() {
						loadDefault();
					});
				</script>
			</cfif>
		<cfelse>
			
		</cfif>
	</cfloop>
	
	<cfif found_boolean EQ false>
		<span class="color-default">Error: This API does not have a definition.</span>
	</cfif>
	
<cfelse>
	<span class="color-default">Error: This API does not have a definition.</span>
</cfif>