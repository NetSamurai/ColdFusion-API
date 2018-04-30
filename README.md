# ColdFusion API

**Questions & Answers**
Q: Why shouldn't I use the native ColdFusion 2016 API?
A: There is no reason not to use it, this module was developed at the same time that one was released.

Q: What does this package do that the ColdFusion 2016 API does not do?
A: It should work more expansively than the original API, allowing more remote calls for more datatypes, as well as offer API usage statistics and logging per call.

**Install API Front-end**
1) Copy the files in the same directory structure from the repository to a local drive.

2) Find and replace the following strings in all included files:
| Text to Replace  | Replace with |
| ------------- | ------------- |
| yourserver | ColdFusion Server Hostname |
| yourdatasource1 | ColdFusion API Logging Datasource |
| yourdbuser1 | ColdFusion API Database User |
| E:\inetpub\wwwroot\ | ColdFusion Server (www)root Directory |

3) Copy the /cfapi folder from the temporary folder to the ColdFusion web server. 
*Note: Do not rename this folder to a reserved word in ColdFusion Server like "api".*

4) Navigate to https://yourserver/cfapi and you should see a interface similar to <a href="http://htmlpreview.github.io/?https://github.com/ravenmyst/ColdFusion-API/blob/master/cfapi/documentation/screenshot1.png" target="_blank">example 1</a> and <a href="http://htmlpreview.github.io/?https://github.com/ravenmyst/ColdFusion-API/blob/master/cfapi/documentation/screenshot1.png" target="_blank">example 2</a>.

5) Add any CFC's you wish to use to /cfapi/component or any subdirectory in /cfapi. The API will automatically organize them by folder on the front-end.

6) Disable web traffic to https://yourserver/cfapi/config to protect your configuration.

**Add API Definitions**
*This is how the API maps a definition name that is used to call the API, to the method that programatically gets invoked.*

1) Open /cfapi/config/settings.cfc and note the following structure:
```ColdFusion
<cfset api_object = StructNew() />
<cfset api_object.name = "api_one" />
<cfset api_object.component = "cfcs.path.component" />
<cfset api_object.url = "https://www.myserver.com/my_api/api_one/component.cfc?WSDL" />
<cfset api_object.method = "invokeCfcMethod" />
<cfset ArrayAppend(return_array, api_object) />
```

2) Change (and multiply) to match your own definition(s) of CFC Method invocations.

**API Log Set-up (optional)**
1) Create and give permissions to the following table: API_LOG
| Column Name  | Column Type | Data Example
| ------------- | ------------- | ------------- |
| time_stamp | date | 03/13/2018 16:15:21 |
| api_called | varchar(256 bytes) | test_call |
| api_method_called | varchar(256 bytes) | getTestCall |
| calling_application | varchar(256 bytes) | test_application |
| calling_user_id | varchar(256 bytes) | theUserLoggedIn |
| calling_user_ip | varchar(256 bytes) | theIpLoggedIn |
| calling_parameters | clob | {theFullRequest:as,jsonKey:pair} |

**Implementing an API Call**
1) The API wrapper can be invoked like so:
```ColdFusion
<cfinvoke method="executeAPICall" returnvariable="returned_array" component="cfapi.components.yourcomponent">
    <cfinvokeargument name="api_called" value="rits_dev_ips" />
    <cfinvokeargument name="api_log" value="true" />
    <cfinvokeargument name="api_application" value="your_application_name" />
    <cfinvokeargument name="api_user" value="#session.user_id#" />
    <cfinvokeargument name="parameter_1" value="#passed_value_1#" />
</cfinvoke>
```
*Note: Each parameter is numeric and in the order which matches the source component function.*

2) To disable the logging feature on a single call:
```ColdFusion
<cfinvokeargument name="api_log" value="false" />
```

**Blacklist Directory for Usage Statistics**
1) Navigate to api_implementation.cfm and add any ignored directories to this array:
```ColdFusion
<cfset filtered_directory_array = [
                                    "ignoredDirectory1",
                                    "ignoredDirectory2",
                                    "ignoredDirectory3",
                                    "config"
] />
```