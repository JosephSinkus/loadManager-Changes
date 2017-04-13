<cfcomponent>
	<cfsetting enablecfoutputonly="yes" />
	<cfset this.name = "MobileApp" >
	<cfset this.dsnname = trim(listFirst(cgi.SCRIPT_NAME,'/')) >
	<cfset this.SessionManagement = "true" >
    <cfset this.ClientManagement = "false" >
    <cfset this.SetClientCookies = "true" >
    <cfset this.ApplicationTimeout = CreateTimeSpan(10,0,0,0)>
    <cfset this.SessionTimeout = CreateTimeSpan(0,2,0,0) >

	<cfset this.mappings = structNew() />
	<cfset this.mappings["/local"] = getDirectoryFromPath(ExpandPath("../../LoadManagerMobile/"))>


	<cffunction name="OnApplicationStart" >
		<cfset Application.Name = this.name >
		<cfset Application.dsnName_temp = trim(listGetAt(cgi.SCRIPT_NAME, 2, '/') )>
		<cfset Application.dsn = this.dsnname >

		<cfset Application.gAPI='AIzaSyAMvv7YySXPntllOqj7509OH-9N3HgCJmw' > <!---Googple Maps API--->
		<cfset Application.strWebsiteTitle = "Load Manager" > <!--- Remember this does not effect the error template title--->
		<cfset Application.strDeveloperEmailAddress = "ScottW@WeberSystems.com;sumi@techversantinfotech.com" >

    </cffunction>

	<cffunction name="OnApplicationEnd" >

    </cffunction>

	<cffunction name="onSessionStart" access="public" returntype="void" output="false" hint="I initialize the session.">

    </cffunction>

    <cffunction name = "onSessionEnd" returnType = "void" output = "true">
		<cfdump var="session End">
    </cffunction>

    <cffunction name="OnRequestStart" output="false" >
    </cffunction>

    <cffunction name="OnRequest" >
		<cfargument name="targetPage" required="true"/ >
		<cfif IsDefined("URL.reinit")>
			<cfset OnApplicationStart() />
		</cfif>

		<cfset request.webpath = Replace("http://#cgi.http_host##cgi.script_name#", "\", "/", "ALL")>

		<cfset request.fileUploadedtemp = request.webpath & "/fileupload/imgTemp/">
		<cfset request.fileUploadedPer = request.webpath & "/filesUpload/imgPrmnt/">

		<cfinclude template="#arguments.TargetPage#"/>

	</cffunction>

	<cffunction name="onError" returnType="void">
		<cfargument name="Exception" required=true/>
		<cfargument name="EventName" type="String" required=true/>
		<cfdump var="#arguments#"><cfabort>
	</cffunction>
</cfcomponent>
