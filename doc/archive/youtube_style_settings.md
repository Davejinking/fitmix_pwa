# YouTube スタイル設定画面実装完了

## 概要
FitMix PS0プロジェクトにYouTubeモバイルアプリと同様のスタイルの設定画面を実装しました。

## 実装内容

### 1. 全体UI構造

**ファイル:** `lib/pages/settings_page.dart`

**特徴:**
- YouTubeスタイルのクリーンなデザイン
- ダークモード完全対応 (黒ベース #000000)
- ライトモード対応 (白ベース #FFFFFF)
- セクション分けされた設定項目

### 2. テーマ選択機能

#### 最上部に配置
```
外観
├── テーマ
    └── 端末の設定に合わせる / ライトモード / ダークモード
```

#### モーダルボトムシート
- ドラッグハンドル付き
- RadioListTileで3つのオプション:
  - 端末の設定に合わせる (ThemeMode.system)
  - ライトモード (ThemeMode.light)
  - ダークモード (ThemeMode.dark)
- 選択即時反映
- 自動dismiss

### 3. セクション構成

#### 外観
- テーマ (palette_outlined)

#### アカウント
- プロフィール設定 (person_outline)
- 通知 (notifications_none)

#### データとバックアップ
- トレーニング履歴 (history)
- 同期設定 (cloud_sync_outlined)

#### アプリ情報
- バージョン情報 (info_outline)
- 実験的な機能 (science_outlined)

#### その他
- ログアウト (logout) - 赤色

### 4. コンポーネント構造

#### `_SettingsSectionHeader`
セクションヘッダーウィジェット
```dart
_SettingsSectionHeader(label: '外観')
```

#### `_SettingsTile`
設定項目タイル
```dart
_SettingsTile(
  leading: Icon(Icons.palette_outlined),
  title: 'テーマ',
  subtitle: '端末の設定に合わせる',
  onTap: () {},
)
```

**パラメータ:**
- `leading`: アイコン
- `title`: タイトル
- `subtitle`: サブタイトル (オプション)
- `titleColor`: タイトル色 (オプション)
- `onTap`: タップハンドラ
- `showChevron`: 右矢印表示 (デフォルト: true)

#### `_ThemeSelectorModal`
テーマ選択モーダル
```dart
_ThemeSelectorModal(
  currentThemeMode: _currentThemeMode,
  onThemeModeChanged: (newMode) {
    // テーマ変更処理
  },
)
```

### 5. テーマ変更フロー

```
1. ユーザーが「テーマ」をタップ
   ↓
2. モーダルボトムシートが表示
   ↓
3. ユーザーがオプションを選択
   ↓
4. SettingsRepoに保存
   ↓
5. FitMixAppの_loadTheme()を呼び出し
   ↓
6. アプリ全体のテーマが更新
   ↓
7. モーダル自動クローズ
```

### 6. ダークモード対応

**ダークモード:**
- 背景: `Colors.black`
- テキスト: `Colors.white`
- サブテキスト: `Colors.grey[400]`
- アイコン: `Colors.white`
- Divider: デフォルト

**ライトモード:**
- 背景: `Colors.white`
- テキスト: `Colors.black87`
- サブテキスト: `Colors.grey[600]`
- アイコン: `Colors.black87`
- Divider: デフォルト

### 7. 使用方法

#### HomePage から設定画面を開く
```dart
IconButton(
  icon: const Icon(Icons.settings_outlined),
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          userRepo: widget.userRepo,
          exerciseRepo: widget.exerciseRepo,
          settingsRepo: widget.settingsRepo,
          sessionRepo: widget.sessionRepo,
          authRepo: widget.authRepo,
        ),
      ),
    );
  },
)
```

## レイアウト構造

```
┌─────────────────────────────────┐
│ ← 設定                          │ AppBar
├─────────────────────────────────┤
│ 外観                            │ Section Header
│ 🎨 テーマ                       │ Tile
│    端末の設定に合わせる    >    │
├─────────────────────────────────┤
│ アカウント                      │ Section Header
│ 👤 プロフィール設定        >    │ Tile
│ 🔔 通知                    >    │ Tile
├─────────────────────────────────┤
│ データとバックアップ            │ Section Header
│ 🕐 トレーニング履歴        >    │ Tile
│ ☁️  同期設定               >    │ Tile
├─────────────────────────────────┤
│ アプリ情報                      │ Section Header
│ ℹ️  バージョン情報         >    │ Tile
│    v1.0.0                       │
│ 🧪 実験的な機能            >    │ Tile
├─────────────────────────────────┤
│                                 │
│ 🚪 ログアウト                   │ Tile (赤)
│                                 │
└─────────────────────────────────┘
```

## テーマ選択モーダル

```
┌─────────────────────────────────┐
│         ━━━━                    │ Drag Handle
│                                 │
│         テーマ                  │ Title
│                                 │
│ ○ 端末の設定に合わせる          │ Radio
│ ● ライトモード                  │ Radio (選択)
│ ○ ダークモード                  │ Radio
│                                 │
└─────────────────────────────────┘
```

## コード品質

```bash
flutter analyze
```

**結果:**
- ✅ エラーなし
- ✅ 警告なし

## 特徴

### 1. YouTubeスタイル
- クリーンなデザイン
- セクション分け
- アイコン + テキスト + 矢印
- モーダルボトムシート

### 2. ダークモード完全対応
- 黒ベース (#000000)
- 適切なコントラスト
- 読みやすいテキスト

### 3. 拡張性
- 新しいセクション追加が容易
- 新しい設定項目追加が容易
- i18n対応準備済み

### 4. UX
- タップ即時反映
- モーダル自動クローズ
- 現在の設定値表示

## 今後の拡張

### 実装予定の機能
- [ ] 通知設定画面
- [ ] トレーニング履歴画面
- [ ] 同期設定画面
- [ ] 実験的な機能画面

### i18n対応
現在は日本語ハードコード。将来的に:
```dart
// 現在
title: 'テーマ'

// 将来
title: context.l10n.theme
```

## まとめ

YouTubeスタイルの設定画面が完成しました。テーマ選択機能を最上部に配置し、セクション分けされた設定項目が続く構造です。ダークモード完全対応で、拡張性の高い設計になっています。
