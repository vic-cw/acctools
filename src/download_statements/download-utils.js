
function DownloadUtils(){}

DownloadUtils.dirname = function(path) {
	
	if( !path || path.indexOf('/') === -1 )
		return '.';

	if( (path.match(/\//g) || []).length === 1){
		if(path.indexOf('/') === 0 )
			return '';
		if(path.indexOf('/') === path.length - 1)
			return '.';
	}
	if( path[path.length -1] === '/')
		path = path.substring(0, path.length -1);
	var splitPath = path.split('/');
	splitPath.pop();
	return splitPath.join("/");
}

DownloadUtils.WRONG_PASSWORD_FORMAT_SITUATION = "wrongPasswordFormat";
DownloadUtils.WRONG_BANK_USERNAME_OR_PASSWORD_SITUATION = "wrongUsernameOrPassword";
DownloadUtils.AUTHENTICATION_SUCCESSFUL_SITUATION = "authenticationSuccessful";

DownloadUtils.assessAuthenticationSituation = function( 
	wrongPasswordFormatSituation, wrongUsernameOrPasswordSituation, successSituation, doc){

		if(arguments.length < 4)
			var doc = document;

		if( doc.querySelector("#Password.ValidError") !== null )
			return wrongPasswordFormatSituation;

		if( doc.querySelector("#actionContentDiv.actionContentDiv") !== null && 
			doc.querySelector("#actionContentDiv.actionContentDiv").innerHTML === "Invalid Authentication" )
			return wrongUsernameOrPasswordSituation;
		
		if( doc.getElementById("CAPToken") !== null && doc.getElementById("btn1") !== null )
			return successSituation;

		return "";
}

DownloadUtils.WRONG_TOKEN_SITUATION = "wrongTokenSituation";
DownloadUtils.SUCCESSFUL_TOKEN_SITUATION = "success";

DownloadUtils.assessTokenSituation = function(
	wrongTokenSituation, successSituation, doc){

		if(arguments.length < 3 )
			var doc = document;
		
		if(	doc.getElementById("actionContentDiv") !== null && 
			doc.getElementById("actionContentDiv").textContent === "Invalid Authentication" )
			return wrongTokenSituation;
		if( doc.getElementById("MainMenu_AcctsCards") !== null )
			return successSituation;
		else
			return "";
}

module.exports = DownloadUtils;
