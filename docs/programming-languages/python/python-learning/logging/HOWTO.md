## 参考記事

https://docs.python.org/ja/3/howto/logging.html

https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/python-logging.html

https://qiita.com/amedama/items/b856b2f30c2f38665701

## Python で Lambda の高度なログ記録コントロールをする簡単な例
ごく簡単な例は:

```
import logging
logger = logging.getLogger()
logger.setLevel("DEBUG")

logger.debug('hello')
```

