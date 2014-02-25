iBeaconInfo
===========

iBeaconのレンジング情報を表示するサンプルコード

### 要件
本サンプルコードを動かすには、iOS 7.0以降および Bluetooth 4.0に対応したiOSデバイスが必要になります。iOSシミュレータでは動作しません。

利用デバイスのBluetooth機能および、位置情報サービスをONにした状態で使用してください。

### 機能概要
* 指定したproximityUUIDをもつiBeaconのレンジング結果を表示する
* ビーコン情報を距離(accuracy)で昇順表示する
* ビーコン情報をmajor/minor番号で昇順表示する

### カスタマイズ
RangingTableViewController.m にある以下の文字列定数を変更することでレンジング対象のproximityUUIDを変更できます。デフォルトではEstimoteのUUIDになっています。

```
static NSString* const kDefaultBeaconProximityUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
```

### ソフトウェアライセンスについて
This software is released under the MIT License, see LICENSE.md.
