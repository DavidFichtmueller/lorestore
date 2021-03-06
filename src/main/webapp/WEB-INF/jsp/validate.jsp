<%@ include file="/WEB-INF/jsp/oreInclude.jsp" %>
<%@ include file="/WEB-INF/jsp/emmetUIInclude.jsp"%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Validate Annotation</title>
   <%@ include file="header.jsp" %>
   <link rel="stylesheet" href="/lorestore/flintsparql/lib/codemirror.css"/>
   <link rel="stylesheet" href="/lorestore/flintsparql/lib/javascript.css"/>
   <link rel="stylesheet" href="/lorestore/flintsparql/lib/xml.css"/>
   <link type="text/css" href="/lorestore/stylesheets/font-awesome.min.css" rel="stylesheet">
  </head>
  <body>  
    <%@ include file="menu.jsp" %>
    
    <div class="container">
      <div class="content">
        <div class="page-header main-page-header">
          <h1>Validate Annotation</h1>
        </div>
          
          <textarea class="input-block-level span10" rows="15" name="data" id="data">
{
    "@context": "http://www.w3.org/ns/oa-context-20130208.json", 
    "@id": "http://www.example.org/annotations/anno1", 
    "@type": "oa:Annotation",

    "annotatedAt": "2012-11-10T09:08:07Z", 
    "annotatedBy": {
        "@id": "http://www.example.org/people/person1", 
        "@type": "foaf:Person", 
        "mbox": {
            "@id": "mailto:person1@example.org"
        }, 
        "name": "Person One"
    },

    "hasBody": {
        "@id": "urn:uuid:1d823e02-60a1-47ae-ae7f-a02f2ac348f8", 
        "@type": ["cnt:ContentAsText", "dctypes:Text"], 
        "chars": "This is part of our logo",
        "cnt:characterEncoding": "UTF-8"
    }, 
    "hasTarget": {
        "@id": "urn:uuid:cc2c8f08-3597-4d73-a529-1c5fed58268b", 
        "@type": "oa:SpecificResource", 
        "hasSelector": {
            "@id": "urn:uuid:7978fa7b-3e03-47e2-89d8-fa39d1280765", 
            "@type": "oa:FragmentSelector", 
            "conformsTo": "http://www.w3.org/TR/media-frags/", 
            "value": "xywh=10,10,5,5"
        }, 
        "hasSource": {
            "@id": "http://www.example.org/images/logo.jpg", 
            "@type": "dctypes:Image"
        }
    },
    "motivatedBy": "oa:commenting"
}
          </textarea>
          <label class="radio">
            <input type="radio" name="contentType" value="application/json" checked> JSON-LD
          </label>
          <label class="radio">
            <input type="radio" name="contentType" value="application/rdf+xml"> RDF/XML
          </label>
          <label class="radio">
            <input type="radio" name="contentType" value="application/trix"> TriX
          </label>
          <label class="radio">
            <input type="radio" name="contentType" value="application/x-turtle"> Turtle
          </label>
          <label class="radio">
            <input type="radio" name="contentType" value="application/x-trig"> TriG
          </label>
          <div class="form-actions">
          <button id="validate" class="btn">Validate</button>
          </div>
          
          <div id="result">
          </div>
      </div>
     <%@ include file="footer.jsp" %>
     <script type="text/javascript" src="/lorestore/mustache.js"></script>
     <script type="text/javascript" src="/lorestore/flintsparql/lib/codemirror.js"></script>
     <script type="text/javascript" src="/lorestore/flintsparql/lib/xml.js"></script>
     <script type="text/javascript" src="/lorestore/flintsparql/lib/javascript.js"></script>
     <script type="text/javascript">
     // TODO support other modes and switch between for xml, TriX, TriG
     var cmEditor = CodeMirror.fromTextArea(document.getElementById('data'), {
         mode: "",
         lineNumbers: true,
         tabMode: "indent"
     });
     
     function renderResult(){
          var result = this? this.result : "";
           // if the result is an array, process results
           // otherwise display result to String
           if (typeof result !== 'string' && result){
               var resultString = "";
               for (var i = 0; i < result.length; i++) {
                   var row = result[i];
                   for (var p in row){
                       if (row.hasOwnProperty(p)){
                           resultString +=  p + ": " + row[p] + "\n";
                       }
                   }
               }
               return "<pre>" + resultString + "</pre>";
           } else { 
               
               return result? "<em>" + result + "</em>" : "";
           }
     }
     var summaryTemplate = "<h3>Summary</h3>" + 
     "<p>Validated against {{total}} rules: <span class='pass'>Passed: {{pass}}</span> <span class='error'>Errors: {{error}}</span> <span class='warn'>Warnings: {{warn}}</span> <span class='skip'>Skipped: {{skip}}</span></p>" +
     "<hr class='mute'>";
     var sectionTemplate = "<h2><i class='{{status}} icon-{{status}}'></i> Section {{section}}</h2>" +
     "<p>Section Summary: <span class='pass'>Passed: {{pass}}</span> <span class='error'>Errors: {{error}}</span> <span class='warn'>Warnings: {{warn}}</span> <span class='skip'>Skipped: {{skip}}</span></p>" +
       "<hr class='mute'>" +
       "{{#constraints}}" +
       "<div><h3 class='{{status}}' title='{{status}}'><i class='icon-{{status}}'></i> " + 
       "{{ref}}</h3><p><a style='color:#333333' target='_blank' href='{{url}}'>{{description}}</a>" + 
       "<br/>{{{renderResult}}}" + 
       "</p>" + 
       "</div>" +
       "{{/constraints}}" +
       "<hr class='mute'>";
     jQuery("input:radio[name=contentType]").change(function(){
         var contentType = jQuery('input:radio[name=contentType]:checked').val();
         if (contentType == "application/rdf+xml" || contentType=="application/trix"){
             cmEditor.setOption("mode","xml");
         } else if (contentType == "application/json"){
             cmEditor.setOption("mode",{name: "javascript", json: true});
         } else {
             cmEditor.setOption("mode","");
         }
     });
     jQuery('#validate').click(function(ev){
         var data = cmEditor.getValue();
         var contentType = jQuery('input:radio[name=contentType]:checked').val();
         jQuery('#result').empty();
         jQuery.ajax({
             type: 'POST',
             url: '/lorestore/oa/validate/',
             headers: {
                 'Accept': 'application/json',
                 'Content-Type': contentType
             },
             processData: false,
             data: data.toString(),
             success: function(d){
                 
                 jQuery('#result').append("<h2>Validation Results</h2>");
                 jQuery('#result').append(Mustache.render(summaryTemplate,d));
                 var result = "";
                 var detailedResults = d.result;
                 for(var i =0; i < detailedResults.length; i++){
                     var section = detailedResults[i];
                     section.renderResult = renderResult;
                     jQuery('#result').append(Mustache.render(sectionTemplate,section));
                 }
                 jQuery('#result').append("<p>Legend: <span class='pass'><i class='icon-pass'></i> Passed</span> <span class='error'><icon class='icon-error'></i> Error</span> <span class='warn'><icon class='icon-warn'></i> Warning</span> <span class='skip'><i class='icon-skip'></i> Skipped</span></p>");
             },
             error: function(e){
                 jQuery('#result').append("<div class='error'>" + e.responseText + "</div>");
             }
         })
         return false;
     })
     </script>
    </div>
  </body>
</body>
</html>
