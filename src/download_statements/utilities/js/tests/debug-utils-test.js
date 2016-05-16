
var chai = require('chai');
var expect = chai.expect;

var DebugUtils = require('./../../../debug-utils');

var debug;

var defaultNumber = "42";
var defaultFolder = '/path/to';
var defaultCasper = {};


describe('DebugUtils', function(){

	it('constructor should throw an error if less than 3 arguments are provided', function(){
		var testFunction = function(){ DebugUtils.create() };

		expect( testFunction ).to.throw(/Missing argument/);
	});

	it('constructor should throw an error if first argument is empty string', function(){
		var testFunction = function(){ DebugUtils.create("", defaultFolder, defaultCasper) };

		expect( testFunction ).to.throw(/Invalid argument/);
	});

	it('constructor should throw an error if second argument is empty string', function(){
		var testFunction = function(){ DebugUtils.create(defaultNumber, "", defaultCasper) };

		expect( testFunction ).to.throw(/Invalid argument/);
	});

	it('constructor should throw an error if third argument is null', function(){
		var testFunction = function(){ DebugUtils.create(defaultNumber, defaultFolder, null) };

		expect( testFunction ).to.throw(/Invalid argument/);
	});

	it('getSessionTimeStamp() should return value provided to constructor', function(){
		var number = "1234";
		debug = DebugUtils.create(number, defaultFolder, defaultCasper);

		expect(debug.getSessionTimeStamp()).to.equal(number);
	});

	it('log() should call logger provided to constructor', function(){
		var buffer = "";
		var logger = function(msg) {
			buffer = msg;
		}
		var msg = "hello world";
		debug = DebugUtils.create(defaultNumber, defaultFolder, defaultCasper, logger);

		debug.log(msg);

		expect(buffer).to.equal(msg);
	});

	it('getFolder() should return folder provided to constructor and timestamp '+
		'if folder provided ends with a slash', function(){
			var number = "5678";
			var folder = "/path/to/"
			debug = DebugUtils.create(number, folder, defaultCasper);

			expect(debug.getFolder()).to.equal(folder + number);
		});

	it('getFolder() should return folder provided to constructor, a slash, and '+
		'timestamp if folder provided doesn\'t end with a slash', function(){
			var number = "91011";
			var folder = '/path/to';
			debug = DebugUtils.create(number, folder, defaultCasper);

			expect(debug.getFolder()).to.equal(folder + '/' + number);
		});

	it('capture() should call capture method of casper object, passing correct file path', function(){
		var number = "121314";
		var folder = '/path/to';
		var fileName = 'file';
		var fileCaptured = '';
		var casper = {
			capture: function(path){
				fileCaptured = path;
			}
		};
		debug = DebugUtils.create(number, folder, casper);

		debug.capture(fileName);

		expect(fileCaptured).to.equal(debug.getFolder()+'/'+fileName);

	});
});

