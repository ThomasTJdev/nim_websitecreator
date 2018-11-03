


const editor = grapesjs.init({
  container: '#gjs',
  fromElement: true,
  width: '100%',
  height: '100vh',

  assetManager: {
    assets: [],
    noAssets: 'No <b>images</b> here, drag to upload',
    upload: '/files/upload/grapesjs',
    uploadName: 'file',
    openAssetsOnDrop: 1,
    autoAdd: false
  },

  storageManager: {
    type: 'simple-storage',
    stepsBeforeSave: 10
  },

  plugins: ['grapesjs-blocks-bootstrap4'],
  pluginsOpts: {
    'grapesjs-blocks-bootstrap4': {}
  },
  canvas: {
    styles: [
      '/css/style.css',
      '/css/style_custom.css'
    ],
    scripts: [
      //'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js', // Bootstrap
      //'https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js', // Bootstrap
      '/js/js.js',
      '/js/js_custom.js'
    ],
  }
});


var pfx = editor.getConfig().stylePrefix;
var modal = editor.Modal;
var cmdm = editor.Commands;
var codeViewer = editor.CodeManager.getViewer('CodeMirror').clone();
var pnm = editor.Panels;
var container = document.createElement('div');
var btnEdit = document.createElement('button');

codeViewer.set({
    codeName: 'htmlmixed',
    readOnly: 0,
    theme: 'hopscotch',
    autoBeautify: true,
    autoCloseTags: true,
    autoCloseBrackets: true,
    lineWrapping: true,
    styleActiveLine: true,
    smartIndent: true,
    indentWithTabs: true
});

btnEdit.innerHTML = 'Edit';
btnEdit.className = pfx + 'btn-prim ' + pfx + 'btn-import';
btnEdit.onclick = function() {
    var code = codeViewer.editor.getValue();
    editor.DomComponents.getWrapper().set('content', '');
    editor.setComponents(code.trim());
    modal.close();
};

cmdm.add('html-edit', {
    run: function(editor, sender) {
        sender && sender.set('active', 0);
        var viewer = codeViewer.editor;
        modal.setTitle('Edit code');
        if (!viewer) {
            var txtarea = document.createElement('textarea');
            container.appendChild(txtarea);
            container.appendChild(btnEdit);
            codeViewer.init(txtarea);
            viewer = codeViewer.editor;
        }
        var InnerHtml = editor.getHtml();
        var Css = editor.getCss();
        modal.setContent('');
        modal.setContent(container);
        codeViewer.setContent(InnerHtml + "<style>" + Css + '</style>');
        modal.open();
        viewer.refresh();
    }
});

pnm.addButton('options',
    [
        {
            id: 'edit',
            className: 'fa fa-edit',
            command: 'html-edit',
            attributes: {
                title: 'Edit'
            }
        }
    ]
);


grapeJsLoadAssets();

editor.on('asset:upload:response', (response) => {
  if (response == "ERROR") {
    notifyError("Error uploading")
  } else {
    console.log(response);
    const am = editor.AssetManager;
    am.add(response);
    am.render();
  }
});


const SimpleStorage = {};

editor.StorageManager.add('simple-storage', {
  store(data, clb, clbErr) {
    $("#gjshidden").val(editor.getHtml() + "<style>" + editor.getCss() + "</style>")
    savePage();
  }
});
