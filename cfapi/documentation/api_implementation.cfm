<cfsetting requesttimeout="600">

<cfif isDefined('url.ajax')>
	<cfset directory_prefix = "E:\inetpub\wwwroot\" />
	<cfdirectory directory="#directory_prefix#" recurse="yes" action="LIST" name="baseDirCfm" filter="*.cfm">
	<cfdirectory directory="#directory_prefix#" recurse="yes" action="LIST" name="baseDirCfc" filter="*.cfc">
	
	<cfinvoke method="getAPIDefinition" returnvariable="api" component="cfapi.config.settings" />

	<cffunction name="checkValidDirectory" returntype="boolean" output="yes">
		<cfargument name="path" type="string">

		<cfset filtered_directory_array = [
										"ignoredDirectory1",
										"ignoredDirectory2",
										"ignoredDirectory3",
										"config"
		] />

		<cfset return_boolean = true />

		<cfset evaluated_directory = ReplaceNoCase(path, directory_prefix, "", "ALL") />

		<cfif Find("\", evaluated_directory, 1)>
			<cfset evaluated_directory = Mid(evaluated_directory, 1, Find("\", evaluated_directory, 1)-1)/>
		</cfif>

		<cfif ArrayFind(filtered_directory_array, evaluated_directory)>
			<cfset return_boolean = false />
		</cfif>

		<cfreturn return_boolean />
	</cffunction>

	<cfset base_array = ArrayNew(1) />

	<cfloop query="baseDirCfm">
		<cfset isValidDirectory = checkValidDirectory(baseDirCfm.Directory) />
		<cfif isValidDirectory>
			<cfset tempDirectoryLocation = baseDirCfm.Directory & '\' & baseDirCfm.Name />
			<cfset ArrayAppend(base_array, tempDirectoryLocation) />
		</cfif>
	</cfloop>

	<cfloop query="baseDirCfc">
		<cfset isValidDirectory = checkValidDirectory(baseDirCfc.Directory) />
		<cfif isValidDirectory>
			<cfset tempDirectoryLocation = baseDirCfc.Directory & '\' & baseDirCfc.Name />
			<cfset ArrayAppend(base_array, tempDirectoryLocation) />
		</cfif>
	</cfloop>

	<cfset result_struct = StructNew() />
	<cfset usage_struct = StructNew() />

	<cfloop array="#base_array#" item="theFile">
		<cffile action="READ" file="#theFile#" variable="fileText" />
		<cfloop array="#api#" index="api_definition">
			<cfset search_string = "<cfinvokeargument name=.{1}api_called.{1} value=.{1}#api_definition.name#.{1}>"/>
			<cfset search_string = trim(search_string) />
			<cfset test_search_string_struct = ReFindNoCase(search_string, fileText, 1, true, "ALL")>
			<cfif ArrayLen(test_search_string_struct) GT 0>
				<cfloop array="#test_search_string_struct#" index="theMatch">
					<cfif ArrayLen(theMatch.match) NEQ 0>
						<cfloop array="#theMatch.match#" index="position">
							<cfif position NEQ "">
								<cfset struct = StructNew() />
								<cfset struct.api_used = api_definition.name />
								<cfset project = "" />
								<cfset project = ReplaceNoCase(theFile, directory_prefix, "", "ALL")>
								<cfset script_path = "" />
								<cfset script_path = Mid(project, Find("\", project, 1)+1, Len(project)) />
								<cfset project = Mid(project, 1, Find("\", project, 1)-1) />
								<cfset struct.project = project />
								<cfset struct.script_path = ReplaceNoCase(script_path, "\", "/", "ALL") />
								<!--- get logging --->
								<cfset search_log_string = "<cfinvokeargument name=.{1}api_log.{1} value=.{1}false.{1}>"/>
								<cfset test_search_log_string_struct = ReFindNoCase(search_log_string, fileText, 1, true, "ALL")>
								<cfset struct.logging = true />
								<cfif ArrayLen(test_search_log_string_struct) GT 0>
									<cfloop array="#test_search_log_string_struct#" index="logMatch">
										<cfif ArrayLen(logMatch.match) NEQ 0>
											<cfloop array="#logMatch.match#" index="logPosition">
												<cfif logPosition NEQ "">
													<cfset struct.logging = false />
												</cfif>
											</cfloop>
										</cfif>
									</cfloop>
								</cfif>
								<cfif !StructKeyExists(result_struct, project)>
									<cfset result_struct[project] = ArrayNew(1) />
									<cfset ArrayAppend(result_struct[project], struct) />
								<cfelse>
									<cfset ArrayAppend(result_struct[project], struct) />
								</cfif>
								<cfif !StructKeyExists(usage_struct, struct.api_used)>
									<cfset usage_struct[struct.api_used] = 0 />
									<cfset usage_struct[struct.api_used] += 1 />
								<cfelse>
									<cfset usage_struct[struct.api_used] += 1 />
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cfloop>
</cfif>


<html>
	<cfif !isDefined('url.ajax')>
	<head>
		<title>API Usage</title>
		<cfoutput>
			<cfset templatePath = "cfapi/assets" />
			<script src="/#EncodeForHTML(templatePath)#/js/jquery.min.js"></script>
			<link rel="shortcut icon" href="/#EncodeForHTML(templatePath)#/img/favicon_statistics.ico" type="image/x-icon" />
			<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/include.css">
		</cfoutput>
	</head>
	
	<body>
		<div id="result_div"></div>
	</body>
	
	<script>
	$(function() {
		$('#result_div').html("<span class='headerSimple'><br />Generating API Implementation Statistics... Please wait...<br /></span><img src='/assets/img/progress.gif'>");

		$.get("api_implementation.cfm?ajax",
			function (data, status) {
				$('#result_div').html(data);
			}
		)
	});
	</script>
	
	<cfelse>
		<cfoutput>
			<h3 class="headerSimple" style="font-size: 20px;"><img src="/#EncodeForHTML(templatePath)#/img/favicon_statistics.ico" /> API Implementation Statistics</h3>
			<table>
				<tr>
					<th class="color-default" style="border-bottom: 1px dashed ##ffcc00 !important; font-size: 18px" colspan="2" align="left">Calls by Application:</th>
				</tr>
				<cfloop collection="#result_struct#" item="key">
				<tr>
					<td class="header">#key#</td>
					<td class="header">
						<cfloop array="#result_struct[key]#" index="pair">
							<span class="color-one-simple">#pair.api_used#</span> : <span class="color-default">#pair.script_path#</span> 
							<cfif pair.logging eq false>
								: Logging Disabled
							</cfif>
							<br />
						</cfloop>
					</td>
				</tr>
				</cfloop>
			</table>

			<br />

			<table>
				<tr>
					<th class="color-default" style="border-bottom: 1px dashed ##ffcc00 !important; font-size: 18px" colspan="2" align="left">Call breakdown by Type:</th>
				</tr>
				<cfset total_integer = 0 />
				<cfloop collection="#usage_struct#" item="key">
					<tr>
						<td class="header">#key#</td>
						<td class="header">
							<span class="color-one-simple">#usage_struct[key]#</span><br />
						</td>
					</tr>
					<cfset total_integer += usage_struct[key] />
				</cfloop>
				<tr>
					<td class="header">TOTAL</td>
					<td class="header">
						<span class="color-one-simple">#total_integer#</span>
					</td>
				</tr>
			</table>

		</cfoutput>
	</cfif>
	
</html>