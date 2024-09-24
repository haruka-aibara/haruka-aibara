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

## Ruff 用
https://qiita.com/LaserBit/items/8dfd410ef65c19053ce2
```
    "[python]": {
        "editor.codeActionsOnSave": {
            "source.fixAll": "explicit",
            "source.organizeImports": "explicit"
        },
        "editor.defaultFormatter": "charliermarsh.ruff"
    },
    "ruff.lineLength": 120,
    "ruff.lint.ignore": [
        "F401"
    ],
    "ruff.lint.preview": true,
    "ruff.lint.select": [
        "C",
        "E",
        "F",
        "W",
        "I"
    ],
    "ruff.logFile": "~/logs/ruff.log",
    "ruff.logLevel": "debug",
    "ruff.nativeServer": "on",
```
