#!/bin/bash
# ========================================================================
# extract_terraform_resources.sh
#
# このスクリプトは、Terraformファイル（.tf）からリソースブロックを抽出し、
# 「resource_type.resource_name」の形式でファイルに出力します。
#
# 使い方:
#   ./extract_terraform_resources.sh [出力ファイル名]
#
# 引数:
#   [出力ファイル名] - オプション。出力を保存するファイル名。
#                     指定しない場合は「terraform_resources.txt」が使用されます。
#
# 例:
#   ./extract_terraform_resources.sh                  # デフォルトのファイル名で実行
#   ./extract_terraform_resources.sh resources.txt    # カスタムファイル名で実行
#
# 注意:
#   - カレントディレクトリとそのサブディレクトリ内のすべての.tfファイルを検索します。
#   - 重複したリソース名は削除されます。
# ========================================================================

# ヘルプフラグが指定された場合に使い方を表示
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  echo "使い方:"
  echo "  $0 [出力ファイル名]"
  echo ""
  echo "引数:"
  echo "  [出力ファイル名] - オプション。出力を保存するファイル名。"
  echo "                   指定しない場合は「terraform_resources.txt」が使用されます。"
  exit 0
fi

# Check if output file is provided as argument
if [ $# -eq 0 ]; then
  OUTPUT_FILE="terraform_resources.txt"
else
  OUTPUT_FILE="$1"
fi

echo "Terraformリソースを検索中..."

# Clear output file if it exists
> "$OUTPUT_FILE"

# Find all .tf files and extract resource names
find . -name "*.tf" | while read -r tf_file; do
  # Use grep to find resource blocks and process with sed
  grep "^resource" "$tf_file" | sed -E 's/^[ \t]*resource[ \t]+"([^"]+)"[ \t]+"([^"]+)".*/\1.\2/' >> "$OUTPUT_FILE"
done

# Sort the output file and remove duplicates
sort -u -o "$OUTPUT_FILE" "$OUTPUT_FILE"

echo "処理完了: リソースリストは $OUTPUT_FILE に保存されました"
echo "検出されたリソース数: $(wc -l < "$OUTPUT_FILE")"
