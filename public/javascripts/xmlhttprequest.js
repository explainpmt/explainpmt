/**
* Cross-browser XMLHttpRequest instantiation.
*/

if (typeof XMLHttpRequest == 'undefined') {
 XMLHttpRequest = function () {
   var msxmls = ['MSXML3', 'MSXML2', 'Microsoft']
   for (var i=0; i < msxmls.length; i++) {
     try {
       return new ActiveXObject(msxmls[i]+'.XMLHTTP')
     } catch (e) { }
   }
   throw new Error("No XML component installed!")
 }
}
