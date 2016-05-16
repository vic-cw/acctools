
var chai = require('chai');
var expect = chai.expect;

var du = require('./../../../download-utils');

describe('DownloadUtils', function(){
	
	describe('dirname()', function(){

		it('dirname() should return \'.\' if no argument is provided', function(){
			expect(du.dirname()).to.equal('.');
		});

		it("dirname() should return '.' if argument contains no path separator", function(){
			expect(du.dirname('file')).to.equal('.');
		});

		it("dirname() should return empty string if argument is a file name at the root", function(){
			expect(du.dirname('/file')).to.equal('');
		});

		it("dirname() should return '.' if argument contains a path separator only as trailing slash", function(){
			expect(du.dirname('file/')).to.equal('.');
		});

		it("dirname() should return everything until the last slash "+
			"if there is at least one slash neither trailing nor leading", function(){
			expect(du.dirname('path/tofile')).to.equal('path');
		});

		it("dirname() should return everything until the last middle slash "+
			"if there are both a trailing slash and at least one middle slash", function(){
				expect(du.dirname('path/to/file/')).to.equal('path/to');
			});

	})

	describe('assessAuthenticationSituation()', function(){

		var arg1 = 1, arg2 = 2, arg3 = 3;

		it('assessAuthenticationSituation should return empty string if document.querySelector '+
			'and document.getElementById always return null', function(){
				
				var document = {
					querySelector : function() {return null;},
					getElementById : function() {return null;}
				};

				expect(du.assessAuthenticationSituation(arg1, arg2, arg3, document)).to.equal('');
			});

		it('assessAuthenticationSituation should return argument 1 if '+
			'document.querySelector("#Password.ValidError") isn\'t null', function(){

				var document = {
					querySelector : function(arg) { 
						return (arg === "#Password.ValidError" ? "non-null string" : null); }
				}

				expect(du.assessAuthenticationSituation(arg1, arg2, arg3, document)).to.equal(arg1);
		});

		it('assessAuthenticationSituation should return argument 2 in case of invalid authentication', function(){
				var document = {
					querySelector : function(arg) { 
						return (arg === "#actionContentDiv.actionContentDiv" ? {innerHTML: "Invalid Authentication"} : null); }
				};

				expect(du.assessAuthenticationSituation(arg1, arg2, arg3, document)).to.equal(arg2);
		});

		it('assessAuthenticationSituation should return argument 3 in case of elements of id '+
			'CAPToken and btn1', function(){

				var document = {
					querySelector : function(){ return null; },
					getElementById : function(arg){
						if( arg === "CAPToken" || arg === "btn1" )
							return "something";
						return null;
					}
				};

				expect(du.assessAuthenticationSituation(arg1, arg2, arg3, document)).to.equal(arg3);
			});

		it('assessAuthenticationSituation should return empty string if it has only element '+
			'actionContentDiv and its content isn\'t the expected string', function(){

				var document = {
					getElementById : function() { return null; },
					querySelector : function(arg){ 
						return (arg == "#actionContentDiv.actionContentDiv" ? {innerHTML: "some string"} : null); }
				};

				expect(du.assessAuthenticationSituation(arg1, arg2, arg3, document)).to.equal('');
			});

		it('assessAuthenticationSituation should return empty string if it has one element of success'+
			' but not the other', function(){

				var document = {
					getElementById : function(arg) { return (arg==="CAPToken" ? "some string" : null); },
					querySelector : function() { return null; }
				};

				expect(du.assessAuthenticationSituation(arg1, arg2, arg3, document)).to.equal('');
			});
	});


	describe('assessTokenSituation', function(){

		var arg1 = 1, arg2 = 2;

		it('assessTokenSituation should return empty string if document doesn\'t have any element', function(){
			var document = {
				getElementById : function(){ return null; }
			};

			expect(du.assessTokenSituation(arg1, arg2, document)).to.equal('');
		});

		it('assessTokenSituation should return empty string if document has a actionContentDiv element '+
			'but with an invalid content', function(){
				var document = {
					getElementById : function(arg) { 
						return (arg === "actionContentDiv") ? {textContent : "some string"} : null; 
					}
				}

				expect(du.assessTokenSituation(arg1, arg2, document)).to.equal('');
			});

		it('assessTokenSituation should return its first argument if document has an element '+
			'actionContentDiv with the correct content', function(){
				var document = {
					getElementById : function(arg){
						return {textContent : "Invalid Authentication"};
					}
				}

				expect(du.assessTokenSituation(arg1, arg2, document)).to.equal(arg1);
			});

		it('assessTokenSituation should return its second argument if document has an element '+
			'MainMenu_AcctsCards', function(){
				var document = {
					getElementById : function(arg){
						return (arg === "MainMenu_AcctsCards") ? "something" : null;
					}
				}

				expect(du.assessTokenSituation(arg1, arg2, document)).to.equal(arg2);
			});


	});


});