
function DebugUtils(timestamp, folder, casper, logger){
	for(var i=0; i<3; i++)
		if(typeof arguments[i] === "undefined")
			throw new Error("Missing argument : 3 arguments are required");
	if( timestamp == "" )
		throw new Error("Invalid argument : timestamp should be provided as non empty string");
	if( folder == "" )
		throw new Error("Invalid argument : folder should be provided as non empty string");
	if( ! casper )
		throw new Error("Invalid argument : provided casper object should be non null");

	this.sessionTimeStamp = timestamp;
	this.folder = folder + ( folder[folder.length-1] !== '/' ? '/' : '' ) +
					timestamp;
	this.casper = casper;
	this.logger = logger ? logger : console.log;
}

DebugUtils.prototype.getSessionTimeStamp = function(){
	return this.sessionTimeStamp;
}

DebugUtils.prototype.log = function(msg) {
	this.logger(msg);
}

DebugUtils.prototype.getFolder = function(){
	return this.folder;
}

DebugUtils.prototype.capture = function(filePath){
	this.casper.capture(this.folder + '/' + filePath);
}


module.exports = DebugUtils;

module.exports.create = function(timestamp, folder, casper, logger){ 
	return new DebugUtils(timestamp, folder, casper, logger);
};