// Settings

const ABA_URL = "https://secure.ababank.com/";

const TIMEOUT = 45000;

const MISSING_ARGUMENTS_EXIT_CODE = 1;
const WRONG_BANK_USERNAME_OR_PASSWORD_EXIT_CODE = 2;
const WRONG_PASSWORD_FORMAT = 3;
const TIMED_OUT_EXIT_CODE = 100;

const SCREENSHOT_WIDTH = 1024;
const SCREENSHOT_HEIGHT = 768;


var casper = require('casper').create({
	pageSettings: {
        loadImages:  false,
        loadPlugins: false
    }
});


// Check arguments

if( !casper.cli.has('username') || 
	!casper.cli.has('pwd') || 
	!casper.cli.has('token') ||
	!casper.cli.has('start-date') ||
	!casper.cli.has('end-date') ||
	!casper.cli.has('file-base-name')){

	casper.echo("Error: missing arguments. 6 arguments are required : "+
		"username, password, CAP card token, start date, end date, and file base name. "+
		"Use following syntax : \n"+
		"casperjs download_aba_statements.js --username=JohnDoe --pwd=1234 --token=98390394820 "+
		"--start-date=12/02/2015 --end-date=14/02/2015 --file-base-name=/path/to/file");
	casper.exit(MISSING_ARGUMENTS_EXIT_CODE);
}

// Read arguments

var username 				= casper.cli.raw.get('username');
var password 				= casper.cli.raw.get('pwd');
var token 	 				= casper.cli.raw.get('token');
var startDate 				= casper.cli.get('start-date');
var endDate 				= casper.cli.get('end-date');
var destinationFileBaseName = casper.cli.get('file-base-name');
var debug 					= casper.cli.has('vdebug') && ( casper.cli.get('vdebug') === true );


// Set up general tools

var fs = require('fs');

var scriptName = fs.absolute( require("system").args[3] );
var scriptDirectory = scriptName.substring(0, scriptName.lastIndexOf('/'));

var du = require(scriptDirectory+'/download-utils.js');


// Set up debug tools

if (debug){

	debug = require( du.dirname(scriptName)+'/debug-utils' ).create(
		Date.now(),
		du.dirname(scriptName) + "/debug",
		casper,
		function log(msg) { 
			console.log( "     " + msg ) 
		});

	debug.log("Debug mode enabled");

	debug.log("Debug folder : "+debug.getFolder());
}

if(debug)
	debug.log("Username : "+username+", token : "+token+", startDate : "+
		startDate+", endDate : "+endDate+", destination files base name : "+
		destinationFileBaseName);

if(debug)
	casper.on('remote.message', function(message) {
	    debug.log("Page console: " + message);
	});


// Open page

casper.echo("Opening page...");

casper.start(ABA_URL);


if(debug)
	casper.viewport(SCREENSHOT_WIDTH, SCREENSHOT_HEIGHT);

if(debug)
	casper.page.onError = function (msg, trace) {	
	    debug.log("Page error log: " + msg);
	    trace.forEach(function(item) {
	        debug.log('  ', item.file, ':', item.line);
	    });
    };


// Wait for page to load

casper.waitFor(function check(){
	return this.evaluate(function(){
		return 	document.getElementById("Name") !== null &&
				document.getElementById("Password") !== null &&
				document.querySelector(".newbtnbodywrap[onclick]") !== null ;});
}, function then(){
	this.echo("Logging in...");

}, function timeout(){
	this.echo("Timed out while trying to reach "+ABA_URL);
	this.exit(TIMED_OUT_EXIT_CODE);
});


// Fill username and password

casper.then(function(){
	this.sendKeys("#Name", username);
	this.sendKeys('#Password', password);
	this.click(".newbtnbodywrap[onclick]");
	if(debug)
		debug.capture("0_after_typing_credentials.png");
});


// Wait for CAP card token prompt to load

var authenticationSituation = "";

casper.waitFor(function check(){
	authenticationSituation = this.evaluate(
								du.assessAuthenticationSituation,
								du.WRONG_PASSWORD_FORMAT_SITUATION,
								du.WRONG_BANK_USERNAME_OR_PASSWORD_SITUATION,
								du.AUTHENTICATION_SUCCESSFUL_SITUATION);
	return authenticationSituation !== "";

}, function then(){

	switch(authenticationSituation){

		case du.WRONG_PASSWORD_FORMAT_SITUATION:
			this.echo("Error: wrong password format");
			if(debug){
				debug.capture("1_wrong_password_format.png");
				debug.log("Screenshots have been saved in "+debug.getFolder());
			}
			this.exit(WRONG_PASSWORD_FORMAT);
			return;

		case du.WRONG_BANK_USERNAME_OR_PASSWORD_SITUATION:
			this.echo("Error: wrong username or password");
			this.echo("Warning: after 3 failed attemps, ABA bank blocks internet banking for your account");
			if(debug){
				debug.capture("1_wrong_username_or_password.png");
				debug.log("Screenshots have been saved in "+debug.getFolder());
			}
			this.exit(WRONG_BANK_USERNAME_OR_PASSWORD_EXIT_CODE);
			return;

		case du.AUTHENTICATION_SUCCESSFUL_SITUATION:
			this.echo("Verifying CAP Token...");
			if(debug)
				debug.capture("1_before_typing_cap_token.png");
			break;

		default:
			if(debug) debug.log("Wrong value stored in authenticationSituation : "+authenticationSituation);
	}
}, function timeout() {
	this.echo("Timeout waiting for CAP card token prompt.");
	if(debug){
    	debug.capture("1_timeout_waiting_for_token_prompt.png");
		debug.log("Screenshots have been saved in "+debug.getFolder());
	}
    this.exit(TIMED_OUT_EXIT_CODE);
}, TIMEOUT);


// Input CAP card token

casper.then(function(){

	this.fill("form#frmCAPToken", {'CAPToken': token});
	if(debug)
		debug.capture("2_cap_token_inputted.png");

	this.click("#btn1");
	if(debug)
		debug.capture("3_cap_token_sent.png");
});


// Wait for token to be verified

var tokenSituation = "";

casper.waitFor(function check(){
	tokenSituation = this.evaluate(
						du.assessTokenSituation,
						du.WRONG_TOKEN_SITUATION,
						du.SUCCESSFUL_TOKEN_SITUATION
					);
	return tokenSituation !== "";
}, function then(){
	if(debug)
		debug.capture("4_answer_on_cap_token.png");
}, function timeout(){
	this.echo("Timed out while waiting for answer on CAP card token")
	if(debug)
		debug.log("Screenshots have been saved in "+debug.getFolder());
	this.exit(TIMED_OUT_EXIT_CODE);
}, TIMEOUT);

casper.then(function(){

	// If wrong token, inform user and quit

	if(tokenSituation === du.WRONG_TOKEN_SITUATION){
		this.echo("Authenticaton failed: wrong CAP token");
		this.echo("Warning : after 3 failed attemps, ABA bank blocks internet banking for your account");
		if(debug){
			debug.capture("5_wrong_cap_token.png");
			debug.log("Screenshots have been saved in "+debug.getFolder());
		}
		this.exit(WRONG_BANK_USERNAME_OR_PASSWORD_EXIT_CODE);
	}

	// If correct, go to accounts page

	else {
		this.echo("Logged in");
		this.click("#MainMenu_AcctsCards");
	}
});


// Wait for accounts page to be loaded

casper.waitFor(function check(){
	return this.evaluate(function(){
		return 	document.getElementById("AcctsInfoTabs_OperHist") !== null && 
				document.getElementById("fromDate") !== null && 
				document.getElementById("toDate") !== null &&
				document.getElementById("btnMakeHistory") !== null;
	});
}, function then(){
	this.echo("Generating data...");
}, function timeout(){
	this.echo("Timed out while waiting for accounts page to load");
	if(debug)
		debug.capture("6_timeout_waiting_for_accounts.png");
		debug.log("Screenshots have been saved in "+debug.getFolder());
	this.exit(TIMED_OUT_EXIT_CODE);
}, TIMEOUT);


// Specify starting and ending dates for statement

casper.then(function(){

	this.click("#AcctsInfoTabs_OperHist");
	
	this.evaluate(function(startDate, endDate){
		document.getElementById("fromDate").value = startDate;
		document.getElementById("toDate").value = endDate;
	}, startDate, endDate);
	if(debug)
		debug.capture("6.1_dates_inputted.png");

	this.click("#btnMakeHistory");
});

// Wait until data are loaded

casper.waitFor(function check(){
	return this.evaluate(function(){
		if(	document.getElementById("tblOperHistResults") !== null &&
			document.getElementById("save_img") !== null && 
			document.getElementById("pdf_img") !== null && 
			document.getElementById("xls_img") !== null )
			return true;

		// If page stopped trying, click again

		if( ! document.getElementById("divOperHistResultsWrapContainer") || 
			document.getElementById("divOperHistResultsWrapContainer").getElementsByClassName("wait").length === 0){

			document.getElementById("btnMakeHistory").click();
		}
		return false;
	});
}, function then(){
	this.echo("Data generated");
	if(debug)
		debug.capture("7_data_loaded.png");
	this.echo("Downloading statements...");
}, function timeout(){
	this.echo("Timed out while waiting for data on accounts");
	if(debug){
		debug.capture("7_timeout_waiting_for_data.png");
		debug.log("Screenshots have been saved in "+debug.getFolder());
	}
	this.exit(TIMED_OUT_EXIT_CODE);
}, TIMEOUT);


// Download statements

/* 
Because of limitations of CasperJS and PhantomJS, it is not possible to simply click
on the buttons to download the statements. Thus, the code below reproduces some logic
which is written on ABA's website, and makes an AJAX request.
*/

// Download csv

var csvDestinationFile = destinationFileBaseName + ".csv";

casper.then(function(){

	/* This logic reproduces the exact logic of ABA's website */

	var payload = this.evaluate(function(){

		function cleanHtmlText(htmlText){
			var text = htmlText.replace(new RegExp('\r', 'g'), '')
			           			.replace(new RegExp('\n', 'g'), ' ');
			while( text.indexOf('  ') != -1 ){
			    text = text.replace(new RegExp('  ', 'g'), ' ');
			}
		  	return text;
		};
		return "html=" + encodeURIComponent(encodeURIComponent(
				"<table>" +
				cleanHtmlText( 
					$('#tblOperHistResultsHold', '#divMain').html()+
					$('#tblOperHistResults', '#divMain').html()  ) +
				"</table>"));
	});

	/* */

	var csvBase64results = this.base64encode('/csv', 'POST', payload);

	var csvDecodedResults = atob(csvBase64results);
	
	fs.write(csvDestinationFile, csvDecodedResults, 'w');

	this.echo("CSV file saved in '"+csvDestinationFile+"'");
});


// Download pdf

var pdfDestinationFile = destinationFileBaseName + ".pdf";

casper.then(function(){

	/* This logic reproduces the exact logic of ABA's website */

	var payload = this.evaluate(function(){
		return "html=" + 
			encodeURIComponent(encodeURIComponent(
				$('#printDivStampHead').html()+
				$('#printDiv').html()+
				$('#printDivStamp').html() )) +
			"&css=" + 
			encodeURIComponent(encodeURIComponent(
				$('#PDFHistStyle').html() ));
	});

	/* */

	var pdfBase64Results = this.base64encode('/pdf', 'POST', payload);

	var pdfDecodedResults = atob(pdfBase64Results);

	fs.write(pdfDestinationFile, pdfDecodedResults, 'wb');

	this.echo("PDF file saved in '" + pdfDestinationFile + "'");
});


// Download xls

var xlsDestinationFile = destinationFileBaseName + ".xlsx";

casper.then(function(){

	/* This logic reproduces the exact logic of ABA's website */
	
	var payload = this.evaluate(function(){
		function cleanHtmlText(htmlText){
			var text = htmlText.replace(new RegExp('\r', 'g'), '')
			           			.replace(new RegExp('\n', 'g'), ' ');
			while(text.indexOf('  ')!=-1){
			    text = text.replace(new RegExp('  ', 'g'), ' ');
			}
		  	return text;
		};
		var tblHold = $('#tblOperHistResultsHold', '#divMain').clone();
		var tblFinished = $('#tblOperHistResults', '#divMain').clone();
		if(tblFinished.length > 0){
			$(".noexportXLS", tblHold).remove();
			$(".noexportXLS", tblFinished).remove();
			$(".exportXLS", tblHold).removeClass("noexport noexportCSV");
			$(".exportXLS", tblFinished).removeClass("noexport noexportCSV");

			return "html=" + encodeURIComponent(encodeURIComponent(
				"<table>" +
				cleanHtmlText(
					tblHold.html()+
					tblFinished.html() )+
				"</table>"
					));
		}
	});

	/* */

	var xlsBase64Results = this.base64encode('/xls', 'POST', payload);

	var xlsDecodedResults = atob(xlsBase64Results);

	fs.write(xlsDestinationFile, xlsDecodedResults, 'wb');

	this.echo("XLS file saved in '" + xlsDestinationFile + "'");
});



// Log out

casper.then(function(){
	this.echo("Logging out...");
	this.click("#divExitPic");
});

casper.waitForSelector("#mainbody.mainLogonBody", 
	function then(){
		this.echo("Logged out");
		if(debug){
			debug.capture("8_logged_out.png");
			debug.log("Screenshots have been saved in "+debug.getFolder());
		}
		this.exit(0);
	},
	function onTimeOut(){
		this.echo("Timed out while logging out");
		if(debug)
			debug.log("Screenshots have been saved in "+debug.getFolder());
		this.exit(0);
	},
	TIMEOUT
);


casper.run();