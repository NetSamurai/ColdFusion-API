<cffunction name="ArrayOfStructSort" returntype="array" access="public" output="no">
	<cfargument name="base" type="array" required="yes" />
	<cfargument name="sortType" type="string" required="no" default="text" />
	<cfargument name="sortOrder" type="string" required="no" default="ASC" />
	<cfargument name="pathToSubElement" type="string" required="no" default="" />

	<cfset var tmpStruct = StructNew()>
	<cfset var returnVal = ArrayNew(1)>
	<cfset var i = 0>
	<cfset var keys = "">

	<cfloop from="1" to="#ArrayLen(base)#" index="i">
	<cfset tmpStruct[i] = base[i]>
	</cfloop>

	<cfset keys = StructSort(tmpStruct, sortType, sortOrder, pathToSubElement)>

	<cfloop from="1" to="#ArrayLen(keys)#" index="i">
	<cfset returnVal[i] = tmpStruct[keys[i]]>
	</cfloop>

	<cfreturn returnVal>
</cffunction>

<cffunction name="JavaREMatch" access="remote" returnType="array" description="This function calls a regex match on a string using the underlying Java in Coldfusion." hint="This will require Java regex syntax to work.">
	<cfargument name="matchExpression" type="string" required="true" hint="(?i)(?<=Path## )[A-Z]{1,2}[\d]{2}[-]{1}.*?(?=<br>)">
	<cfargument name="matchString" type="string" required="true" hint="The Pathology Report Path## S01-23456">
		<cfset var resultSet = []>
		<cfset objPattern = CreateObject(
			"java",
			"java.util.regex.Pattern"
			).Compile(
				matchExpression
				) />

		<cfset objMatcher = objPattern.Matcher(matchString) />

		<cfloop condition="objMatcher.Find()">

			<cfset ArrayAppend(resultSet, objMatcher.Group()) />

		</cfloop>

	<cfreturn resultSet>
</cffunction>

<cffunction name="REMatchPage" access="remote" returntype="array" output="yes" description="This extends JavaREMatch by allowing a page to be passed as a parameter to only match part of a string." hint="This will require Java regex syntax to work.">
	<cfargument name="theExpression" type="string" required="true" hint="(?i)(?<=Path## )[A-Z]{1,2}[\d]{2}[-]{1}.*?(?=<br>)">
	<cfargument name="theString" type="string" required="true" hint="The Pathology Report Path## S01-23456">
	<cfargument name="pageNumber" type="numeric" required="true" hint="1">
	
		<cfset var resultSet = []>
		<cfset var theStringArray = []>
		<cfset var currentPageArray = []>
		<cfset var currentPage = "">

		<cfset var pageDelimiter = RepeatString("=", 66)>

		<cfset theStringArray = ListToArray(theString, pageDelimiter,"yes","yes")>

		<cfif ArrayLen(theStringArray) GT pageNumber>
		
		

			<cfset currentPage = theStringArray[pageNumber]>
			<cfset resultSet = JavaREMatch(theExpression, currentPage)>         
		 </cfif>

	<cfreturn resultSet>
</cffunction>