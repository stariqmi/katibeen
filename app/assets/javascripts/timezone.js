 //Uses the jstz-1.0.4.min.js in app/assets/javascript
 //Check if the document has been loaded
 $(document).ready(function() {
 	var tz = jstz.determine(); 		// Determines the time zone of the browser client
	var user_tz = tz.name();		// Extract the name of the timezone 
	$("#timezone").val(user_tz);	// Set it to the value of the hidden input field in the signup form 
									// with the id timezone
 });
 