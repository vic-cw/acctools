
const CONVERTER_URL = 	"file://localhost" + phantom.libraryPath + 
						"/csv_converter_html/www.convertcsv.com/csv-to-csv.htm";

// Get input from argument

var args = require('system').args;

if(args.length < 2) {
	console.log("Error: no data provided to convert from semi-colon csv to comma csv");
	phantom.exit(1);
}

var input = args[1];


// Start

var page = require('webpage').create();

page.open(CONVERTER_URL, function(){

	// Make DOM manipulations

	var result = page.evaluate(function(input){

		document.getElementById('chkHeader').click();
		document.getElementById('sepSemicolon').click();
		document.getElementById('txt1').value = input;
		document.getElementById('txt1').onchange();
		document.getElementById('outSepComma').checked = true;
		document.getElementById('btnRun').click();

		return document.getElementById('txta').value;

	}, input);

	// Output result

	console.log(result.trim());

	// Exit

	phantom.exit(0);
});