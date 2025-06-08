# CFG Scale（Classifier Free Guidance Scale）

## 概要
CFG Scaleは、拡散モデル（Diffusion Models）における生成プロセスの制御パラメータの一つです。特にStable Diffusionなどのテキスト条件付き画像生成モデルで重要な役割を果たします。このパラメータは、生成される画像がプロンプト（テキスト指示）にどれだけ忠実に従うかを制御します。

## 詳細

### 基本的な仕組み
- プロンプトの影響度を調整するスケーリング係数
- 値が大きいほどプロンプトへの忠実度が高くなる
- 値が小さいほど創造性が高くなる
- 通常は1.0から20.0の範囲で設定

### 重要な特徴
- プロンプトの制御性を向上
- 生成画像の品質と多様性のバランスを調整
- アン条件付き生成と条件付き生成の間の補間を制御
- 生成プロセスの安定性に影響

### 使用シーン
- テキスト条件付き画像生成
- 画像編集
- スタイル転送
- 画像の品質向上

## 具体例

### Pythonでの実装例（Stable Diffusion）
```python
from diffusers import StableDiffusionPipeline
import torch

# モデルの初期化
model_id = "runwayml/stable-diffusion-v1-5"
pipe = StableDiffusionPipeline.from_pretrained(
    model_id,
    torch_dtype=torch.float16
).to("cuda")

# 異なるCFG Scale値での生成
prompt = "a beautiful sunset over mountains, digital art"
cfg_scales = [1.0, 7.0, 15.0]

for cfg_scale in cfg_scales:
    image = pipe(
        prompt,
        guidance_scale=cfg_scale,
        num_inference_steps=50
    ).images[0]
    image.save(f"output_cfg_{cfg_scale}.png")
```

### CFG Scaleの効果
1. 低い値（1.0-5.0）
   - より創造的な生成
   - プロンプトからの逸脱が大きい
   - 予測不可能な結果

2. 中間の値（5.0-10.0）
   - バランスの取れた生成
   - プロンプトへの適度な忠実度
   - 一般的な使用に適している

3. 高い値（10.0以上）
   - プロンプトへの高い忠実度
   - より制御された生成
   - 時には過度に制限的な結果

## 実装のポイント
1. プロンプトの性質に応じた調整
   - 具体的な指示には高い値
   - 抽象的な表現には低い値

2. 生成の目的に応じた選択
   - 正確な再現には高い値
   - 創造的な表現には低い値

3. 他のパラメータとの組み合わせ
   - ステップ数との関係
   - シード値の影響
   - サンプラーとの相性

## まとめ
CFG Scaleは、拡散モデルにおける生成プロセスの重要な制御パラメータです。適切な値の選択により、生成される画像の品質とプロンプトへの忠実度のバランスを調整することができます。特にStable Diffusionなどのテキスト条件付き画像生成モデルでは、このパラメータの理解と適切な設定が、望ましい結果を得るための鍵となります。 
