// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
function validateFilesTax(inputFile) {
  var extErrorMessage = "Only RDF file with extension: .rdf, .ttl or .xml is allowed";
  var allowedExtension = ["rdf", "ttl", "xml"];
  var extName;
  var extError = false;
 
  $.each(inputFile.files, function() {
    extName = this.name.split('.').pop();
    if ($.inArray(extName, allowedExtension) == -1) {extError=true;};
  });
 
  if (extError) {
    // window.alert(extErrorMessage);
    $.alert(extErrorMessage, "Wrong File Extension");
    $(inputFile).val('');
  };
}









