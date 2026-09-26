# c7n の Lambda ハンドラ。c7n がデプロイ時に生成するものと同じで、判定はすべて c7n 本体（layer）と
# 同じ zip に入る config.json（ポリシー定義）で決まる。
#
# layer は PyPI の wheel をそのまま使っているので、パッケージは /opt/c7n に展開される。
# Lambda の Python ランタイムが sys.path に入れるのは /opt/python なので、/opt を足してから import する。
import sys

sys.path.insert(0, "/opt")

from c7n import handler  # noqa: E402


def run(event, context):
    return handler.dispatch_event(event, context)
