/// ダウンロード進捗を報告するためのコールバック
/// 
/// [url] ダウンロード中のURLまたはリソース識別子
/// [current] 現在のダウンロード進捗（バイト数）
/// [total] ダウンロードの総サイズ（バイト数）
/// [percentage] 現在の進捗率（0-100の範囲）
typedef DownloadProgressCallback = void Function(
  String url,
  int current,
  int total,
  double percentage,
);

/// 全体的な進捗状況を報告するためのコールバック
/// 
/// [operation] 実行中の操作名（例：「アセットのダウンロード」「ライブラリのダウンロード」など）
/// [completed] 完了したアイテム数
/// [total] 総アイテム数
/// [percentage] 現在の進捗率（0-100の範囲）
typedef OperationProgressCallback = void Function(
  String operation,
  int completed,
  int total,
  double percentage,
);
