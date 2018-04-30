<cfsetting requesttimeout="600">

<style>
.ui-button {
	font-size: 10px !important;
}
</style>

<cfset max_results = 100 />

<cfif isDefined('url.ajax')>
	<cfquery name="getUsageStatistics" datasource="yourdatasource1">
	select		*
	from		yourdbuser1.api_log
	where		1=1
	<cfif isDefined('url.api_called') and url.api_called neq "">
	and			api_called = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.api_called#"  />
	</cfif>
	<cfif isDefined('url.api_method_called') and url.api_method_called neq "">
	and			api_method_called = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.api_method_called#"  />
	</cfif>
	<cfif isDefined('url.calling_application') and url.calling_application neq "">
	and			calling_application = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.calling_application#"  />
	</cfif>
	<cfif isDefined('url.calling_user_id') and url.calling_user_id neq "">
	and			calling_user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.calling_user_id#"  />
	</cfif>
	<cfif isDefined('url.calling_user_ip') and url.calling_user_ip neq "">
	and			calling_user_ip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.calling_user_ip#"  />
	</cfif>
	order by 	time_stamp desc
	fetch next #max_results# rows only
	</cfquery>
	
	<cfquery name="getUsage" datasource="yourdatasource1">
	select		count(*) as COUNT
	from		yourdbuser1.api_log
	where		1=1
	<cfif isDefined('url.api_called') and url.api_called neq "">
	and			api_called = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.api_called#"  />
	</cfif>
	<cfif isDefined('url.api_method_called') and url.api_method_called neq "">
	and			api_method_called = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.api_method_called#"  />
	</cfif>
	<cfif isDefined('url.calling_application') and url.calling_application neq "">
	and			calling_application = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.calling_application#"  />
	</cfif>
	<cfif isDefined('url.calling_user_id') and url.calling_user_id neq "">
	and			calling_user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.calling_user_id#"  />
	</cfif>
	<cfif isDefined('url.calling_user_ip') and url.calling_user_ip neq "">
	and			calling_user_ip = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.calling_user_ip#"  />
	</cfif>
	</cfquery>
</cfif>


<html>
	<cfif !isDefined('url.ajax')>
	<head>
		<title>API Usage</title>
		<cfoutput>
			<cfset templatePath = "cfapi/assets" />
			<link rel="shortcut icon" href="/#EncodeForHTML(templatePath)#/img/favicon_statistics.ico" type="image/x-icon" />
			<link rel="stylesheet" href="/#EncodeForHTML(templatePath)#/css/include.css">
			<script src="/#EncodeForHTML(templatePath)#/js/jquery.min.js"></script>
			<script src="/#EncodeForHTML(templatePath)#/js/jquery-ui.min.js"></script>
			<script src="/#EncodeForHTML(templatePath)#/js/jquery.ui.window-framework.min.js"></script>
		</cfoutput>
	</head>
	
	<body>
		<div id="result_div"></div>
	</body>
	
	<script>
	$(function() {
		$('#result_div').html("<span class='headerSimple'><br />Generating API Usage Statistics... Please wait...<br /></span><img src='/assets/img/progress.gif'>");

		$.get("api_usage.cfm?ajax",
			function (data, status) {
				$('#result_div').html(data);
			}
		)
	});
	
	function requeryWithFilter(old_parameters, parameter, value) {
		$('#result_div').html("<span class='headerSimple'><br />Generating API Usage Statistics... Please wait...<br /></span><img src='/assets/img/progress.gif'>");
		
		$.get("api_usage.cfm" + old_parameters + "&" + parameter + '=' + value,
			function (data, status) {
				$('#result_div').html(data);
			}
		)
	}
	
	function clearFilter(filtered_new_url) {
		$.get("api_usage.cfm" + filtered_new_url,
			function (data, status) {
				$('#result_div').html(data);
			}
		)
	}
	</script>
	
	<cfelse>
		<cfset new_url = "?ajax" />
		<cfloop collection="#url#" item="url_parameter">
			<cfif url_parameter neq "ajax">
				<cfset new_url = new_url & "&" & url_parameter />
				<cfif url[url_parameter] neq "">
					<cfset new_url = new_url & "=" & url[url_parameter] />
				</cfif>
			</cfif>
		</cfloop>

		<cfoutput>
			<h3 class="headerSimple" style="font-size: 20px;">
				<img src="/cfapi/documentation/img/favicon_statistics.ico" />
				API Usage Statistics [ descending #getUsageStatistics.RecordCount# / #getUsage.COUNT# rows displayed ]
				<cfif isDefined('url.api_called') and url.api_called neq "">
					<cfset filtered_new_url = ReplaceNoCase(new_url, "&api_called=" & url.api_called, "", "ALL") />
					<button class="cancelButton" onclick="clearFilter('#filtered_new_url#')">#EncodeForHTML(url.api_called)#</button>
				</cfif>
				<cfif isDefined('url.api_method_called') and url.api_method_called neq "">
					<cfset filtered_new_url = ReplaceNoCase(new_url, "&api_method_called=" & url.api_method_called, "", "ALL") />
					<button class="cancelButton" onclick="clearFilter('#filtered_new_url#')">#EncodeForHTML(url.api_method_called)#</button>
				</cfif>
				<cfif isDefined('url.calling_application') and url.calling_application neq "">
					<cfset filtered_new_url = ReplaceNoCase(new_url, "&calling_application=" & url.calling_application, "", "ALL") />
					<button class="cancelButton" onclick="clearFilter('#filtered_new_url#')">#EncodeForHTML(url.calling_application)#</button>
				</cfif>
				<cfif isDefined('url.calling_user_id') and url.calling_user_id neq "">
					<cfset filtered_new_url = ReplaceNoCase(new_url, "&calling_user_id=" & url.calling_user_id, "", "ALL") />
					<button class="cancelButton" onclick="clearFilter('#filtered_new_url#')">#EncodeForHTML(url.calling_user_id)#</button>
				</cfif>
				<cfif isDefined('url.calling_user_ip') and url.calling_user_ip neq "">
					<cfset filtered_new_url = ReplaceNoCase(new_url, "&calling_user_ip=" & url.calling_user_ip, "", "ALL") />
					<button class="cancelButton" onclick="clearFilter('#filtered_new_url#')">#EncodeForHTML(url.calling_user_ip)#</button>
				</cfif>
			</h3>
		</cfoutput>
		<table width="100%">
			<tr class="color-default">
				<th align="left">Date/Time</th>
				<th align="left">API Definition Called</th>
				<th align="left">API Method Given</th>
				<th align="left">Calling Application</th>
				<th align="left">User ID</th>
				<th align="left">User IP</th>
				<th align="left">Parameters</th>
			</tr>
			<cfoutput query="getUsageStatistics">
				<tr class="color-one-simple">
					<td>#DateFormat(TIME_STAMP, 'mm/dd/yyyy')# #TimeFormat(TIME_STAMP, 'hh:mm tt')#</td>
					<td>
						<cfif isDefined('url.api_called') and url.api_called EQ getUsageStatistics.api_called>
							<span class="color-one-simple">#API_CALLED#</span>
						<cfelse>
							<a class="color-one" onclick="requeryWithFilter('#new_url#', 'api_called', '#api_called#');">#API_CALLED#</a>
						</cfif>
					</td>
					<td>
						<cfif isDefined('url.api_method_called') and url.api_method_called EQ getUsageStatistics.api_method_called>
							<span class="color-one-simple">#API_METHOD_CALLED#</span>
						<cfelse>
							<a class="color-one" onclick="requeryWithFilter('#new_url#', 'api_method_called', '#api_method_called#');">#API_METHOD_CALLED#</a>
						</cfif>
					</td>
					<td>
						<cfif isDefined('url.calling_application') and url.calling_application EQ getUsageStatistics.calling_application>
							<span class="color-one-simple">#CALLING_APPLICATION#</span>
						<cfelse>
							<a class="color-one" onclick="requeryWithFilter('#new_url#', 'calling_application', '#calling_application#');">#CALLING_APPLICATION#</a>
						</cfif>
					</td>
					<td>
						<cfif isDefined('url.calling_user_id') and url.calling_user_id EQ getUsageStatistics.calling_user_id>
							<span class="color-one-simple">#CALLING_USER_ID#</span>
						<cfelse>
							<a class="color-one" onclick="requeryWithFilter('#new_url#', 'calling_user_id', '#calling_user_id#');">#CALLING_USER_ID#</a>
						</cfif>
					</td>
					<td>
						<cfif isDefined('url.calling_user_ip') and url.calling_user_ip EQ getUsageStatistics.calling_user_ip>
							<span class="color-one-simple">#CALLING_USER_IP#</span>
						<cfelse>
							<a class="color-one" onclick="requeryWithFilter('#new_url#', 'calling_user_ip', '#calling_user_ip#');">#CALLING_USER_IP#</a>
						</cfif>
					</td>
					<td>#CALLING_PARAMETERS#</td>
				</tr>
			</cfoutput>
		</table>
	</cfif>
	
</html>

<script>
$(function() {
	loadButtonStyling();
});
</script>