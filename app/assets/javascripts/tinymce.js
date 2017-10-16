$(document).on('ready page:load', function () {
  if (typeof tinyMCE != 'undefined') {
    tinyMCE.init({
      selector: "textarea.tinymce",
      toolbar: [
        "styleselect | bold italic | alignleft aligncenter alignright alignjustify",
        "bullist numlist outdent indent | link image | code | codesample"
      ],
      plugins: "image,link,code,codesample,autoresize,imagetools,media,table,insertdatetime,charmap,print,preview,anchor,searchreplace,visualblocks,fullscreen"
    });
  } else {
    setTimeout(arguments.callee, 50);
  }
});