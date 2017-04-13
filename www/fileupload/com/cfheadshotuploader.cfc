
<cfcomponent hint="I handle AJAX File Uploads from Valum's AJAX file uploader library">
	
    <cffunction name="Upload" access="remote" output="false" returntype="any" returnformat="JSON">
		<cfargument name="qqfile" type="string" required="true">
		<cfargument name="dsn" type="string" required="false">
		
		<cfset var local = structNew()>
		<cfset local.response = structNew()>
		<cfset local.requestData = GetHttpRequestData()>
		<cfset local.response.FILENAME = "">
		
		<CFSET UploadDir = "#ExpandPath('../')#img\">
		
		<!--- Begin : DropBox Integration  ---->
		<cfquery name="qrygetSettingsForDropBox" datasource="#dsn#">
			SELECT 
				DropBox,
				DropBoxConsumerKey,
				DropBoxConsumerToken,
				DropBoxAccessToken
			FROM SystemConfig
		</cfquery>
		<!--- End : DropBox Integration  ---->
		
		<cfif qrygetSettingsForDropBox.DropBox EQ 1 > <!---  Store file @ DropBox  ----> 
			<!--- Begin : DropBox Integration  ---->
			<cfhttp
					method="post"
					url="https://api.dropboxapi.com/2/users/get_current_account"	
					result="returnStruct"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetSettingsForDropBox.DropBoxAccessToken#">		
			</cfhttp> 	
			<cfif returnStruct.Statuscode EQ "200 OK"> <!--- Authorization Success --->
				<cfhttp
						method="GET"
						url="https://api.dropboxapi.com/1/metadata/auto/fileupload/img"	
						result="returnStruct"> 
							<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetSettingsForDropBox.DropBoxAccessToken#">			
				</cfhttp> 
			
				<cfif returnStruct.Statuscode NEQ "200 OK"> <!--- Folder Not Found, Create Folder ---->				
					<cfset tmpStruct = {
						 "path" = '/fileupload/img'
						}>
						<cfhttp
								method="post"
								url="https://api.dropboxapi.com/2/files/create_folder"	
								result="returnStructCreateFolder"> 
										<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetSettingsForDropBox.DropBoxAccessToken#">		
										<cfhttpparam type="HEADER" name="Content-Type" value="application/json">
										 <cfhttpparam type="body" value="#serializeJSON(tmpStruct)#">
						</cfhttp> 						
				</cfif>
				<cfif len(trim(arguments.qqfile))>
						<cffile action="upload"
							 fileField="file"
							 nameconflict="overwrite"
							 destination="#UploadDir#">	
							
							 <cffile action="rename"
								source="#UploadDir#/#cffile.CLIENTFILE#"
								destination="#UploadDir#/#cffile.CLIENTFILENAME#_#DateFormat(now(),'mmddyyyhhmm')#.#cffile.CLIENTFILEEXT#">
								
						<cfset UploadedFile = cffile.CLIENTFILENAME&"_"&DateFormat(now(),'mmddyyyhhmm')&"."&CLIENTFILEEXT>
						<cfoutput>
							<cfset tmpStruct = {"path":"/fileupload/img/#UploadedFile#"
																,"mode":{".tag":"add"}
																,"autorename":true}>
						</cfoutput>
						<cffile action = "readbinary"
								file = "#UploadDir#/#UploadedFile#"
								variable="filcontent">
						<cfhttp
								method="post"
								url="https://content.dropboxapi.com/2/files/upload"	
								result="returnStruct"> 
										<cfhttpparam type="HEADER" name="Authorization" value="Bearer #qrygetSettingsForDropBox.DropBoxAccessToken#">		
										<cfhttpparam type="HEADER" name="Content-Type" value="application/octet-stream">
										<cfhttpparam type="HEADER" name="Dropbox-API-Arg" value="#serializeJSON(tmpStruct)#">
										<cfhttpparam type="body" value="#filcontent#">
						</cfhttp> 
						
						<cffile action="delete" 		file="#UploadDir#/#UploadedFile#">
						<cfset local.response['success'] 			= true>
						<cfset local.response['type']				 = 'form'>
						<cfset local.response.FILENAME		 = '#UploadedFile#'>						
					</cfif>
			<cfelse> <!--- Authorization Fails  ---->
						<cfset local.response['success'] 			= false>						
			</cfif>
			<!--- End : DropBox Integration  ---->
		<cfelse> <!---  Store file Locally  ---->
			<cfif not directoryExists(UploadDir)>
				<cfdirectory action="create" directory="#UploadDir#">
			</cfif>			
			<!--- check if XHR data exists --->
			<cfif len(local.requestData.content) GT 0>
				<cfset local.response = UploadFileXhr(arguments.qqfile,local.requestData.content)>       
			<cfelse>
			<!--- no XHR data process as standard form submission --->
				<cffile action="upload" file="#arguments.qqfile#" destination="#UploadDir#" nameConflict="makeunique">				
				<cfset local.response['success'] = true>
				<cfset local.response['type'] = 'form'>
				<cfset local.response.FILENAME = '#cfFile.ServerFile#'>
			</cfif>
		</cfif>	
		
		<cfreturn local.response>
	</cffunction>
      
    
    <cffunction name="UploadFileXhr" access="private" output="false" returntype="struct">
		<cfargument name="qqfile" type="string" required="true">
		<cfargument name="content" type="any" required="true">
		<cfset var local = structNew()>
		<cfset local.response = structNew()>
		<cfset local.response.FILENAME ="">
		<CFSET UploadDir = "#ExpandPath('../')#img\">

        <!--- write the contents of the http request to a file.  
		The filename is passed with the qqfile variable --->
		<cffile action="write" file="#UploadDir#/#arguments.qqfile#" output="#arguments.content#">

		<!--- if you want to return some JSON you can do it here.  
		I'm just passing a success message	--->
    	<cfset local.response['success'] = true>
    	<cfset local.response['type'] = 'xhr'>
		<cfset local.response.FILENAME = '#arguments.qqfile#'>
		<cfreturn local.response>
    </cffunction>
    <cffunction name="UpdateBillingDocument" access="remote" output="false" returntype="any" returnformat="JSON">
		<cfargument name="attachid" type="numeric" required="true">
		<cfargument name="checkedStatus" type="boolean" required="true">
		<cfargument name="flag" type="boolean" required="true">
		<cfargument name="dsn" type="string" required="true">
		
				<!--- Begin : DropBox Integration  ---->
		<cfquery name="qrygetSettingsForDropBox" datasource="#dsn#">
			SELECT 
				DropBox,
				DropBoxConsumerKey,
				DropBoxConsumerToken,
				DropBoxAccessToken
			FROM SystemConfig
		</cfquery>
		<!--- End : DropBox Integration  ---->
		
		
		<cfif arguments.flag eq 0>
			<cfquery name="qryUpdate" datasource="#dsn#">
				update FileAttachments set 
				Billingattachments=<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.checkedStatus#" >
				<cfif qrygetSettingsForDropBox.DropBox EQ 1 > <!---  Store file @ DropBox  ----> 
					,DropBoxFile = <cfqueryparam cfsqltype="cf_sql_bit" value="1" >
				</cfif>
				where attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachid#" >				
			</cfquery>
		<cfelse>
			<cfquery name="qSystemSetupOptions" datasource="#dsn#">
				update FileAttachmentsTemp set 
				Billingattachments=<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.checkedStatus#">
				<cfif qrygetSettingsForDropBox.DropBox EQ 1 > <!---  Store file @ DropBox  ----> 
					,DropBoxFile = <cfqueryparam cfsqltype="cf_sql_bit" value="1" >
				</cfif>
				where  attachment_Id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.attachid#" >				
			</cfquery>
		</cfif>
		<cfset var localresponse = structNew()>
		<cfset localresponse['attachid'] = arguments.attachid>
		<cfset localresponse['checkedStatus'] = arguments.checkedStatus>
		<cfreturn SerializeJSON(localresponse)>
	</cffunction>	
	
</cfcomponent>