<cfif isDefined('api_path') and !isDefined('method')>

	<cfset cfcPath = ToString ( ToBinary ( api_path ) ) />

	<cfscript>
	apiSource = createObject("component", "#cfcPath#");
	apiMetadata = getMetaData(apiSource);
	</cfscript>
	
	<cfset resourceName = Trim(Right(apiMetadata.fullname, Find(".", Reverse(apiMetadata.fullname), 1)-1)) />
	<cfset resourcePath = Reverse(RemoveChars(Reverse(apiMetadata.fullname), 1, Find(".", Reverse(apiMetadata.fullname), 1)-1)) />

	<cfif IsStruct(apiMetadata) && StructKeyExists(apiMetadata, "functions")>
		<cfset functionsAR = apiMetadata["functions"] />
		<cfinvoke method="ArrayOfStructSort" returnvariable="functionsAR" component="cfapi.component.functions">
			<cfinvokeargument name="base" value="#functionsAR#" />
			<cfinvokeargument name="sortType" value="textnocase" />
			<cfinvokeargument name="sortOrder" value="ASC" />
			<cfinvokeargument name="pathToSubElement" value="name" />
		</cfinvoke>
		<cfoutput>
			<span class="color-default">#EncodeForHTML(Lcase(resourcePath))#</span><span class="header">#EncodeForHTML(Ucase(resourceName))#</span><br /><br />
			<cfset method_row = 1 />
			<div id="method_div">
				<cfloop array = "#functionsAR#" index="function">
					<span id="method_#EncodeForHTMLAttribute(method_row)#_span" class="color-one pointer" onClick="loadAPIFunction('#api_path#','#ToBase64( function["NAME"])#', '#EncodeForJavascript(method_row)#' );" title="#EncodeForHTML(Lcase(resourcePath))##EncodeForHTML(Lcase(resourceName))#{method: #Lcase(EncodeForHTML(function["NAME"]))#}">
						#EncodeForHTML(function["NAME"])#<br />
					</span>
					<cfset method_row += 1 />
				</cfloop>
			</div>
		</cfoutput>
	<cfelse>
		<cfoutput>
			<span class="color-default">#EncodeForHTML(Lcase(resourcePath))#</span><span class="header">#EncodeForHTML(Ucase(resourceName))#</span><br /><br />
			<span class="color-two">There was an error loading this resource.</span>
		</cfoutput>
	</cfif>
<cfelseif isDefined('api_path') and isDefined('method')>

	<cfset cfcPath = ToString ( ToBinary ( api_path ) ) />
	<cfset cfcMethod = ToString ( ToBinary ( method ) ) />
	
	<cfscript>
	apiSource = createObject("component", "#cfcPath#");
	apiMetadata = getMetaData(apiSource);
	</cfscript>
	
	<cfset resourceName = Trim(Right(apiMetadata.fullname, Find(".", Reverse(apiMetadata.fullname), 1)-1)) />
	<cfset resourcePath = ReplaceNoCase(apiMetadata.fullname, resourceName, "", "ALL") />
	
	<cfset apiFunction = StructNew() />
	<cfif IsStruct(apiMetadata) && StructKeyExists(apiMetadata, "functions")>
		<cfset functionsAR = apiMetadata["functions"] />
		<cfloop array = "#functionsAR#" index="function">
			<cfif function["name"] EQ cfcMethod>
				<cfset apiFunction  = function />
			</cfif>
		</cfloop>
	<cfelse>
		<cfoutput>
			<span class="color-default">#EncodeForHTML(Lcase(apiMetadata.fullname))#.</span><span class="header">#EncodeForHTML(Ucase(apiFunction.name))#</span><br /><br />
			<span class="color-two">There was an error loading this resource.</span>
		</cfoutput>
	</cfif>
	<cfoutput>
		<span class="color-default">#EncodeForHTML(Lcase(apiMetadata.fullname))#.</span><span class="header">#EncodeForHTML(Ucase(apiFunction.name))#</span><br /><br />
		<cfset flag_struct = StructNew() />
		<cfset flag_array = ArrayNew(1) />
		<cfset override_flags_array = ["refreshwsdl"] />
		<cfif isDefined('apiFunction.refreshwsdl')>
			<cfset flag_struct['refreshwsdl'] = apiFunction.refreshwsdl />
		<cfelse>
			<cfset flag_struct['refreshwsdl'] = "no" />
		</cfif>
		<cfset ArrayAppend(flag_array, flag_struct) />
		<cfif isDefined('apiFunction.output')>
			<cfset flag_struct = StructNew() />
			<cfset flag_struct['output'] = apiFunction.output />
			<cfset ArrayAppend(flag_array, flag_struct) />
		</cfif>
		<cfif isDefined('apiFunction.returntype')>
			<cfset flag_struct = StructNew() />
			<cfset flag_struct['returntype'] = apiFunction.returntype />
			<cfset ArrayAppend(flag_array, flag_struct) />
		</cfif>
		<cfif isDefined('apiFunction.returnformat')>
			<cfset flag_struct = StructNew() />
			<cfset flag_struct['returnformat'] = apiFunction.returnformat />
			<cfset ArrayAppend(flag_array, flag_struct) />
		</cfif>
		<cfif apiFunction.access EQ "remote">
			<cfif ArrayLen(flag_array) GT 0>
				<span class="headerSimple">Flags {</span>
				<cfloop array="#flag_array#" index="flag">
					<cfloop collection="#flag#" item="flag_type">
						<br /><span class="color-default">#EncodeForHTML(flag_type)#:</span> 
						<cfif ArrayLen(override_flags_array) AND !ArrayFind(override_flags_array, flag_type)>
							<span class="color-one-simple">#EncodeForHTML(flag[flag_type])#</span>
						<cfelse>
							<!--- so far we only have refreshwsdl in cf2016 --->
							<cfset preselect_false = "checked" />
							<cfset preselect_true = "" />
							<label class="radio_label" for="refreshwsdl_yes">yes</label>
							<input class="checkboxradio" type="radio" id="refreshwsdl_yes" name="refreshwsdl" value="yes" #EncodeForHTMLAttribute(preselect_true)#
							data-required="true" data-type="boolean" data-name="refreshwsdl" />
							<label class="radio_label" for="refreshwsdl_no">no</label>
							<input class="checkboxradio" type="radio" id="refreshwsdl_no" name="refreshwsdl" value="no" #EncodeForHTMLAttribute(preselect_false)# 
							data-required="true" data-type="boolean" data-name="refreshwsdl" />
							</cfif>
					</cfloop>
				</cfloop>
				<br /><span class="headerSimple">}</span><br /><br />
			</cfif>
			
			<cfif isDefined('apiFunction.description')>
				<span class="headerSimple">Description:</span> <span class="color-one-simple">#EncodeForHTML(apiFunction.description)#</span><br /><br />
			</cfif>
			<cfif isDefined('apiFunction.hint')>
				<span class="headerSimple">Hint:</span> <span class="color-one-simple">#EncodeForHTML(apiFunction.hint)#</span><br /><br />
			</cfif>
			
			<cfset canRun = true />
			
			<cfif isDefined('apiFunction.parameters')>
				<cfif IsArray(apiFunction.parameters) AND ArrayLen(apiFunction.parameters) GT 0>
					<span class="headerSimple">Parameters {</span><br />
					<cfset parameter_number = 1 />
					<div id="parameter_div" class="color-default">
						<cfloop array="#apiFunction.parameters#" index="parameter">
							<cfif parameter_number NEQ 1>
								<br />
							</cfif>
							<cfset parameter_default = "" />
							<cfif isDefined('parameter.default')>
								<cfset parameter_default = parameter.default />
							</cfif>
							<cfset parameter_hint = "" />
							<cfset width_input = "wideInput" />
							<cfif isDefined('parameter.hint')>
								<cfset parameter_hint = parameter.hint />
								<cfif Len(parameter_hint) GT 20>
									<cfset width_input = "widestInput" />
								</cfif>
							<cfelse>
								<cfset parameter_hint = "input " & parameter.type />
							</cfif>
							<span class="color-default">#EncodeForHTML(parameter.name)#:</span> <span class="color-one-simple">#EncodeForHTML(parameter.type)#</span>
							<cfset element_is_required = false />
							<cfif isDefined('parameter.required')>
								<cfif parameter.required EQ true OR parameter.required EQ "yes">
									<cfset element_is_required = true />
									<span class="color-three">*</span>
								</cfif>
							</cfif>
							<cfswitch expression="#parameter.type#">
								<cfcase value="any|numeric|string|guid|uuid|xml" delimiters="|">
									 <input type="text" class="#EncodeForHTMLAttribute(width_input)#" id="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" name="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" value="#EncodeForHTMLAttribute(parameter_default)#" placeholder="#EncodeForHTMLAttribute(parameter_hint)#" data-required="#EncodeForHTMLAttribute(element_is_required)#" data-type="#EncodeForHTMLAttribute(parameter.type)#" data-name="#EncodeForHTMLAttribute(parameter.name)#" />
								</cfcase>
								<cfcase value="boolean|binary" delimiters="|">
									<cfif parameter_default EQ "true">
										<cfset trueCb = "checked='yes'" />
										<cfset falseCb = "" />
									<cfelseif parameter_default EQ "false">
										<cfset trueCb = "" />
										<cfset falseCb = "checked='yes'" />
									</cfif>
									<label class="radio_label" for="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input_true">true</label>
									<input type="radio" class="checkboxradio" id="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input_true" value="true" name="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" #trueCb# data-required="#EncodeForHTMLAttribute(element_is_required)#" data-type="#EncodeForHTMLAttribute(parameter.type)#" data-name="#EncodeForHTMLAttribute(parameter.name)#" />
									<label class="radio_label" for="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input_false">false</label>
									<input type="radio" class="checkboxradio" id="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input_false" value="false" name="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" #falseCb# data-required="#EncodeForHTMLAttribute(element_is_required)#" data-type="#EncodeForHTMLAttribute(parameter.type)#" data-name="#EncodeForHTMLAttribute(parameter.name)#" />
								</cfcase>
								<cfcase value="date|timestamp" delimiters="|">
									 <input type="text" class="datePicker" id="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" name="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" value="#EncodeForHTMLAttribute(parameter_default)#" placeholder="#EncodeForHTMLAttribute(parameter_hint)#" data-required="#EncodeForHTMLAttribute(element_is_required)#" data-type="#EncodeForHTMLAttribute(parameter.type)#" data-name="#EncodeForHTMLAttribute(parameter.name)#" />
								</cfcase>
								<cfcase value="array">
									<cfif isDefined('parameter.displayname') and parameter.displayname EQ "list">
										 <input type="text" class="#EncodeForHTMLAttribute(width_input)#" id="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" name="parameter_#EncodeForHTMLAttribute(parameter.name)#_#EncodeForHTMLAttribute(parameter_number)#_input" value="#EncodeForHTMLAttribute(parameter_default)#" placeholder="#EncodeForHTMLAttribute(parameter_hint)#" data-required="#EncodeForHTMLAttribute(element_is_required)#" data-type="#EncodeForHTMLAttribute(parameter.type)#" data-name="#EncodeForHTMLAttribute(parameter.name)#" />
									<cfelse>
										N/A
										<cfset canRun = false />
									</cfif>
								</cfcase>
								<cfdefaultcase>
									N/A
									<cfset canRun = false />
								</cfdefaultcase>
							</cfswitch>
							<cfset parameter_number += 1 />
						</cfloop>
					</div>
					<span class="headerSimple">}</span><br /><br />
				</cfif>
			</cfif>
			<cfif canRun EQ true>
				<input type="hidden" id="api_component" name="api_component" value="#EncodeForHTML(Lcase(apiMetadata.fullname))#" />
				<input type="hidden" id="api_method" name="api_method" value="#EncodeForHTML(Lcase(apiFunction.name))#" />
				<button class="playButton" type="button" onClick="loadAPIQuery();">Execute</button>
			</cfif>
			<input type="hidden" id="wrapper_type" name="wrapper_type" value="webservice" />
			<input type="hidden" id="wrapper_dump" name="wrapper_dump" value="false" />
			<div style="float:right"><button class="scriptButton" type="button" onClick="loadAPIWrapper();">Generate Wrapper</button></div>
			<br /><br />
			<div id="result_div"></div>
			
		<cfelse>
			<span class="color-two">This function is not a remote call and cannot be called from the frontend.</span>
		</cfif>
	</cfoutput>
</cfif>

<script>
	$(function() {
		loadDefault();
	});
</script>