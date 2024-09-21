## マークダウンに画像貼り付け時の保存先ディレクトリを定義
```
"markdown.copyFiles.destination": {
  "**/*.md": "assets/${documentBaseName}/"
},
"markdown.copyFiles.overwriteBehavior": "uniqueFilename",
"markdown.editor.drop.copyIntoWorkspace": "always",
"markdown.editor.filePaste.copyIntoWorkspace": "always"
```

## 保存時に改行必須
```
"files.insertFinalNewline": true
```


## Terraform の保存時 自動フォーマット
https://marketplace.visualstudio.com/items?itemName=hashicorp.terraform#formatting
```
"[terraform]": {
  "editor.defaultFormatter": "hashicorp.terraform",
  "editor.formatOnSave": true,
  "editor.formatOnSaveMode": "file"
},
"[terraform-vars]": {
  "editor.defaultFormatter": "hashicorp.terraform",
  "editor.formatOnSave": true,
  "editor.formatOnSaveMode": "file"
}
```
