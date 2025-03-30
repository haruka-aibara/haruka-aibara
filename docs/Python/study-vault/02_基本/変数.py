# 型確認
number = 1
string = "test"
is_test = True

print(number, type(number))
print(string, type(string))
print(is_test, type(is_test))

# 型変換
test = "1"
new_test = int(test)
print(new_test, type(new_test))

# 型定義
test: str = "1"
new_test: int = int(test)
print(new_test, type(new_test))

# invalid syntax 変数名の最初に数字
# 1test = "test"

# invalid syntax 予約語
# if = "test"
