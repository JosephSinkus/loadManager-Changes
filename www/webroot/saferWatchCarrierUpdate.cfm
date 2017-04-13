
<cfoutput>
	<cfinvoke component="#variables.objloadGateway#" method="GetChangedCarriers" returnvariable="variables.message" />
	<cfdump var="#variables.message#">
</cfoutput>