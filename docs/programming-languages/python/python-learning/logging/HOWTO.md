## 参考記事

https://docs.python.org/ja/3/howto/logging.html

https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/python-logging.html

## Python で Lambda の高度なログ記録コントロールをする簡単な例
ごく簡単な例は:

```
import logging
logger = logging.getLogger()
logger.setLevel("DEBUG")

logging.warning('Watch out!')  # will print a message to the console
logging.info('I told you so')  # will not print anything
```

