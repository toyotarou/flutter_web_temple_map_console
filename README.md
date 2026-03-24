# flutter_web_temple_map_console

最終更新日：2026-02-08

## 概要

**寺院（Temple）の参拝記録・位置情報を地図上に可視化する Flutter Web コンソールアプリ**です。

`flutter_map` + OpenStreetMap タイルで東京都の市区町村ポリゴンを表示し、訪問済み寺院のマーカーや未訪問寺院の情報を左右 2 ペインのレイアウトで管理します。鉄道路線・駅データや Navitime ルートデータとも連携しています。

---

## 主な機能

- **東京都市区町村ポリゴン表示**：GeoJSON データから各市区町村の境界を地図上に描画
- **訪問済み寺院のマーカー表示**：参拝日・住所・御本尊・サムネイル・写真などの詳細情報付き
- **未訪問寺院リスト**：訪問済みリストと突き合わせ、未訪問の寺院を抽出して表示
- **駅・鉄道データ連携**：最寄り駅・路線情報を参照
- **Navitime ルートデータ連携**：寺院へのルート情報を保持
- **レスポンシブレイアウト**：画面幅 600px 以上で左右 2 ペイン表示、それ未満では地図のみ表示
- **アプリ再起動機能**：`AppRoot` の `restartApp()` で状態をリセット

---

## 画面構成

```
HomeScreen（LayoutBuilder）
├── LeftScreen（画面幅 20%、≥600px のみ表示）
│   └── 寺院リスト・絞り込み表示
└── RightScreen（Expanded）
    └── flutter_map（地図・ポリゴン・マーカー）
```

---

## ファイル構成

```
lib/
├── main.dart                                     # エントリーポイント（ProviderScope・アプリ再起動）
├── const/                                        # 定数定義
├── controllers/
│   ├── controllers_mixin.dart                    # 全 Controller への統合アクセス Mixin
│   ├── app_param/                                # UI 状態管理（選択寺院・フィルタ等）
│   └── _get_data/
│       ├── get_data/                             # 全データのキャッシュ Hub
│       ├── temple/                               # 訪問済み寺院データ
│       ├── temple_lat_lng/                       # 寺院緯度経度データ
│       ├── temple_list/                          # 寺院リストデータ
│       ├── temple_list_navitime/                 # Navitime ルートデータ付き寺院リスト
│       ├── station/                              # 駅データ
│       ├── tokyo_municipal/                      # 東京都市区町村データ
│       └── tokyo_train/                          # 東京鉄道・路線データ
├── data/                                         # API・データソース定義
├── extensions/                                   # Dart 拡張メソッド
├── models/
│   ├── temple_model.dart                         # 訪問済み寺院モデル
│   ├── temple_lat_lng_model.dart                 # 寺院緯度経度モデル
│   ├── temple_list_model.dart                    # 寺院リストモデル
│   ├── station_model.dart                        # 駅モデル
│   ├── municipal_model.dart                      # 市区町村モデル
│   ├── tokyo_train_model.dart                    # 鉄道・路線モデル
│   └── common/                                   # 共通モデル
├── screens/
│   ├── home_screen.dart                          # メイン画面（左右ペイン振り分け）
│   ├── left_screen.dart                          # 左パネル（寺院リスト）
│   ├── right_screen.dart                         # 右パネル（地図・マーカー・ポリゴン）
│   └── parts/
│       └── temple_cell.dart                      # 寺院リストのセルウィジェット
└── utility/                                      # 地図描画・ユーティリティ関数

assets/
└── json/
    └── tokyo_municipal.geojson                   # 東京都市区町村ポリゴンデータ
```

---

## 主要モデル

### `TempleModel`（訪問済み寺院）

| フィールド     | 型              | 説明                   |
|-------------|----------------|----------------------|
| `date`      | `DateTime`     | 参拝日                  |
| `temple`    | `String`       | 寺院名                  |
| `address`   | `String`       | 住所                   |
| `station`   | `String`       | 最寄り駅                |
| `memo`      | `String`       | メモ                   |
| `gohonzon`  | `String`       | 御本尊                  |
| `startPoint`| `String`       | 出発地点                |
| `endPoint`  | `String`       | 到着地点                |
| `thumbnail` | `String`       | サムネイル画像 URL        |
| `lat`       | `String`       | 緯度                   |
| `lng`       | `String`       | 経度                   |
| `photo`     | `List<String>` | 写真 URL リスト          |

---

## 状態管理

Riverpod（`hooks_riverpod` + `riverpod_annotation`）と Freezed を採用しています。

| Controller           | 役割                                          |
|---------------------|---------------------------------------------|
| `AppParam`          | UI 状態（選択中の寺院・フィルタ条件等）           |
| `GetData`           | 全データの一元キャッシュ Hub                     |
| `Temple`            | 訪問済み寺院データの取得・管理                   |
| `TempleLatLng`      | 寺院の緯度経度データ                            |
| `TempleList`        | 寺院リスト（未訪問フィルタ用）                   |
| `TempleListNavitime`| Navitime ルートデータ付き寺院リスト              |
| `Station`           | 駅データ                                      |
| `TokyoMunicipal`    | 東京都市区町村ポリゴンデータ                     |
| `TokyoTrain`        | 東京鉄道・路線データ                            |

`ControllersMixin` を使うと、各画面の `ConsumerState` から全 Controller の state / notifier に簡潔にアクセスできます。

---

## 依存パッケージ

### dependencies

| パッケージ                    | バージョン   | 用途                              |
|-----------------------------|-------------|----------------------------------|
| `flutter_map`               | `^7.0.2`    | 地図表示（OpenStreetMap）          |
| `latlong2`                  | `^0.9.1`    | 緯度経度の型・計算                  |
| `flutter_riverpod`          | `^2.5.1`    | 状態管理                           |
| `hooks_riverpod`            | `^2.5.1`    | Riverpod + Hooks                 |
| `riverpod_annotation`       | `^2.3.5`    | Riverpod アノテーション             |
| `freezed_annotation`        | `^2.4.1`    | 不変オブジェクト定義                 |
| `json_annotation`           | `^4.9.0`    | JSON シリアライズ                   |
| `cached_network_image`      | `^3.4.1`    | 画像キャッシュ                      |
| `flutter_cache_manager`     | `^3.4.1`    | ファイルキャッシュ（タイル含む）       |
| `scroll_to_index`           | `^3.0.1`    | リストの自動スクロール               |
| `scrollable_positioned_list`| `^0.3.8`    | 位置指定スクロール                  |
| `font_awesome_flutter`      | `^10.7.0`   | アイコン                           |
| `http`                      | `^1.2.1`    | HTTP 通信                         |
| `intl`                      | `^0.20.2`   | 国際化・日付フォーマット             |
| `url_launcher`              | `^6.3.2`    | URL 起動                          |
| `equatable`                 | `^2.0.7`    | 値オブジェクトの等価比較             |
| `flutter_launcher_icons`    | `^0.13.1`   | アプリアイコン生成                  |
| `flutter_native_splash`     | `^2.4.0`    | スプラッシュ画面                    |

### dev_dependencies

| パッケージ            | バージョン   | 用途                       |
|----------------------|-------------|--------------------------|
| `build_runner`       | `^2.4.9`    | コード生成実行              |
| `freezed`            | `^2.5.2`    | Freezed コード生成          |
| `json_serializable`  | `^6.8.0`    | JSON コード生成             |
| `riverpod_generator` | `^2.4.0`    | Riverpod コード生成         |
| `riverpod_lint`      | `^2.3.10`   | Riverpod Lint ルール        |
| `custom_lint`        | `^0.6.4`    | カスタム Lint               |

---

## 環境

| 項目         | バージョン  |
|-------------|-----------|
| Dart SDK    | `^3.8.1`  |

---

## セットアップ

```bash
# リポジトリのクローン
git clone https://github.com/toyotarou/flutter_web_temple_map_console.git
cd flutter_web_temple_map_console

# パッケージの取得
flutter pub get

# コード生成（freezed / riverpod_generator）
dart run build_runner build --delete-conflicting-outputs

# アプリの実行（Web を推奨）
flutter run -d chrome
```

---

## 対応プラットフォーム

- Web（主要ターゲット）
- Android
- iOS
- macOS
- Linux
- Windows
