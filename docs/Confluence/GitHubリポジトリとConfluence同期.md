以下記事を参考に設定を行ったところ、
確かに GitHub リポジトリ上の markdown ファイルをもとに Confluence ページが作成されることは確認できましたアップロードすることは確かにできました。

https://zenn.dev/hattori_sat/articles/docs-confluence-github

ただし、使用する `markdown-confluence/publish-action` は 2023 年からアップデートされておらず、workflow 内で警告も出ていました。

```
(node:1) [DEP0005] DeprecationWarning: Buffer() is deprecated due to security and usability issues. Please use the Buffer.alloc(), Buffer.allocUnsafe(), or Buffer.from() methods instead.
(Use `node --trace-deprecation ...` to show where the warning was created)

Chrome (117.0.5938.92) downloaded to /home/pptruser/.cache/puppeteer/chrome/linux-117.0.5938.92
LAUNCHING CHROME {"executablePath":"/home/pptruser/.cache/puppeteer/chrome/linux-117.0.5938.92/chrome-linux64/chrome","headless":"new","args":["--ignore-certificate-errors","--no-sandbox","--disable-setuid-sandbox","--disable-accelerated-2d-canvas","--disable-gpu"]}
ERROR: Failed to set up Chrome r117.0.5938.92! Set "PUPPETEER_SKIP_DOWNLOAD" env variable to skip download.
[Error: ENOENT: no such file or directory, unlink '/home/pptruser/.cache/puppeteer/chrome/117.0.5938.92-chrome-linux64.zip'] {
  errno: -2,
  code: 'ENOENT',
  syscall: 'unlink',
  path: '/home/pptruser/.cache/puppeteer/chrome/117.0.5938.92-chrome-linux64.zip'
}
```

contributors も 1 名のみであり、今後更新されることも望めないため GitHub リポジトリ上の markdown を Confluence に自動同期することは諦めました。

参考：
https://github.com/markdown-confluence/publish-action

同階層に置いてある yml を用いることで、動作自体は確認できます。
`deploy-markdown-confluence.yml`