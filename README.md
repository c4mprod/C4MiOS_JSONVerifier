C4MiOS_JSONVerifier
===================

What is it?
-----------
This component allows you to ckeck the incoming server JSON streams by comparing it against a standart JSON Schema.
This tool is useful to check a JSON stream before parsing it in order to detect any modification or unexpected data comming from the stream that may compromise your parsing and potentially crash your application.
In case of invalidity, it tells you exactly where's the mismatch via an NSError. 

### Important
This tool is at its early stage and does not fully implement all the JSON Schema specifications (“link” and “rel” missing) , yet it has the majority of the attribut set and it has been successfully tested with dummy and real life data set.
if you encounter any problem, let me know.


Requirements
------------
1. This module requires the SBJSON library designed by Stig Brautaset to parse the data model and user stream. It can be adapted easily to use JSONKit library which is twice faster.
2. It requires also iOS 4 if you want to use the “pattern” feature which uses the official NSRegularExpression object.


How to use it?
--------------
This component was design to be very easy to use. It is composed of a single static method that you call from anywhere in your code.

### Synopsis

	+ (BOOL) checkValidityOf:(NSString *) _userJSON fromModel:(NSString *) _modelJSON error:(NSError **)error;
	
* _userJSON : The user JSON stream to validate.
* _modelJSON : The JSON Data Model stream used for validity check. MUST be compliant with the JSON Model standarts http://tools.ietf.org/html/draft-zyp-json-schema-02
* error : The error containing the error stack messages in case the method returns NO.	

Data Model
----------

Based on the draft of the JSON Schema specifications, the data schema is the hardest part to design for checking the validity of your stream. This data schema is a JSON stream itself and describes all the architecture and elements of the stream to test in a very detail way (such as regex pattern for string attribut or minimum, maximum values for integers and much more).

The C4M_JSONVerifier will check first the integrity of the model before parsing the “server stream”. The response YES or NO from the method strongly depends of the quality and validity of the schema, so make sure this one is correct.

Here is an simple example of the JSON Schema description:

	{
	 "description" : "Example Contact Information Array JSON Schema",
	 "type" : "array",
	 "items" : {
		 "title" : "A Contact Information object",
		 "type" : "object",
		 "properties" : {
		 "name" : {
			 "type" : "string",
			 "enum" : ["home", "work", "other"],
			 "minLength" : 4
		 },
		 "phone" : {
			 "type" : "string",
			 "optional" : true,
			 "format" : "phone"
			 "pattern" : ".3021.*"
		 },
		 "mobile" : {
			 "type" : "string",
			 "optional" : true,
			 "format" : "phone"
		 },
		 "email" : {
			 "type" : "string",
			 "optional" : true,
			 "format" : "email"
		 },
		 "age" : {
			 "type" : "integer",
			 "optional" : true,
			 "minimum" : "7",
			 "maximum" : "77"
		 }
	 },
	 "minItems" : 2,
	 "maxItems" : 3
	 }
 	}

This JSON describes the potential JSON stream that may arrive from the server, for instance:

	[
 		{ "name" : "home", "phone" : "+302109349764", "email": "nico@vahlas.eu", "age" : 30 },
 		{ "name" : "work", "phone" : "+302108029409", "email": "nvah@instore.gr" }
	]

To help you validate the schema, you can use the online JSON Structure checker http://www.jsonlint.com/ 

Example
-------

	NSError *error = nil;
 
	NSString *modelStream = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"real-model" ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
	NSString *testStream = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"real" ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
 
	double start = [[NSDate date] timeIntervalSince1970];
 
	if([C4MJSONVerifier checkValidityOf:testStream fromModel:modelStream error:&error])
	{
		NSLog(@"JSON stream is valid!");
		self.result.text = @"JSON stream is valid!";
	}
	else
	{
		NSLog(@"JSON stream is NOT valid! error :%@", error.localizedDescription);
		self.result.text = [NSString stringWithFormat:@"JSON stream is NOT valid! error :%@", error.localizedDescription];
	}
 
	self.result.text = [self.result.text stringByAppendingString:[NSString stringWithFormat:@"Verified in %f sec", ([[NSDate date] timeIntervalSince1970]- start)]];
 
	[modelStream release];
	[testStream release];


Benchmarks:
-----------

Benchmark on iPod 4th Gen:

* 0,028 sec for 4,580 kb of user JSON
* 0,059 sec for 10,848 kb of user JSON
* 0,118 sec for 29,652 kb of user JSON


Change Logs
-----------

### v1.0

First release