# ColdFusion API

**Questions & Answers**

Q: Why shouldn't I use the native ColdFusion 2016 API?<br />
A: There is no reason not to use it, this module was developed at the same time that one was released.

Q: What does this package do that the ColdFusion 2016 API does not do?<br />
A: It should work more expansively than the original API, allowing more remote calls for more datatypes, as well as offer API usage statistics and logging per call.

Q: Does this work with SOAP or Rest?<br />
A: Although it mostly works with both, it was designed for SOAP.

**Install API Front-end**
1) Copy the files in the same directory structure from the repository to a local drive.

2) Find and replace the following strings in all included files:

| Text to Replace  | Replace with |
| ------------- | ------------- |
| yourserver | ColdFusion Server Hostname |
| yourdatasource1 | ColdFusion API Logging Datasource |
| yourdbuser1 | ColdFusion API Database User |
| E:\inetpub\wwwroot\ | ColdFusion Server (www)root Directory |

3) Copy the /cfapi folder from the temporary folder to the ColdFusion web server. <br />
*Note: Do not rename this folder to a reserved word in ColdFusion Server like "api".*

4) Navigate to https://yourserver/cfapi and you should see a interface similar to <a href="https://github.com/ravenmyst/ColdFusion-API/blob/master/cfapi/documentation/screenshot1.png" target="_blank">Example 1</a> and <a href="https://github.com/ravenmyst/ColdFusion-API/blob/master/cfapi/documentation/screenshot1.png" target="_blank">Example 2</a>.

5) Add any CFC's you wish to use to /cfapi/component or any subdirectory in /cfapi. The API will automatically organize them by folder on the front-end.

6) Disable web traffic to https://yourserver/cfapi/config to protect your configuration.

**Add API Definitions**

This is how the API maps a definition name that is used to call the API, to the method that programatically gets invoked.

1) Open /cfapi/config/settings.cfc and note the following structure:
```ColdFusion
<!--- :: Whatever :: --->
<cfset api_object = StructNew() />
<cfset api_object.name = "whatever_get" />
<cfset api_object.component = "cfapi.component.mycustomdirectory.whatever" />
<cfset api_object.url = "https://www.yourserver.com/cfapi/component/mycustomdirectory/whatever.cfc?WSDL" />
<cfset api_object.method = "getWhatever" />
<cfset ArrayAppend(return_array, api_object) />
```

2) Change (and multiply) to match your own definition(s) of CFC Method invocations.

**API Log Set-up (Optional)**
1) Create table: "API_LOG" and give permissions to "yourdbuser1" in SQL.

| Column Name  | Column Type | Data Example
| ------------- | ------------- | ------------- |
| time_stamp | date | 03/13/2018 16:15:21 |
| api_called | varchar(256 bytes) | whatever_get |
| api_method_called | varchar(256 bytes) | getWhatever |
| calling_application | varchar(256 bytes) | whatever_app |
| calling_user_id | varchar(256 bytes) | resolved_user_id |
| calling_user_ip | varchar(256 bytes) | 1.2.3.4 |
| calling_parameters | clob | {theFullRequest:as,jsonKey:pair} |

**Implementing an API Call**
1) The API wrapper can be invoked like so:
```ColdFusion
<!--- My API Definition #1 --->
<cfinvoke method="executeAPICall" returnvariable="returned_array" component="cfapi.config.settings">
    <cfinvokeargument name="api_called" value="whatever_get" />
    <!--- To disable the logging feature on a single call, set api_log to false --->
    <cfinvokeargument name="api_log" value="true" />
    <!--- To always use local CFC call, not webservice set api_application to 'scheduler' --->
    <cfinvokeargument name="api_application" value="whatever_app" />
    <cfinvokeargument name="api_user" value="#session.user_id#" />
    <cfinvokeargument name="parameter_1" value="#passed_value_1#" />
</cfinvoke>
```
*Note: Each parameter is numeric (up to 20) and in the order which matches the source component function.*

```ColdFusion
<!--- Example Function in whatever.cfc that might be called by this invoker --->
<cffunction name="getWhatever" returntype="array" access="public" output="no" hint="Gets color codes which match the parameter">
    <cfargument name="whatever_parameter" type="string" required="yes" />

    <cfif whatever_parameter eq "dark">
        <cfset return_array = ["#000000","#2F4F4F","#28004B"] />
    <cfelse>
        <cfset return_array = ["#FFFFFF","#9AFFFF","#FFDCE7"] />
    </cfif>

    <cfreturn return_array />
</cffunction>
```

**Blacklist Directory for Usage Statistics**
1) Open /cfapi/documentation/api_implementation.cfm and add any ignored directories to this array:
```ColdFusion
<cfset filtered_directory_array = [
                                    "ignoredDirectory1",
                                    "ignoredDirectory2",
                                    "ignoredDirectory3",
                                    "config"
] />
```