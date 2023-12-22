import 'package:flutter/material.dart';

import 'collections/memo.dart';

import 'memo_repository.dart';
import 'memo_upsert_dialog.dart';

/// メモ一覧画面
class MemoIndexPage extends StatefulWidget {
  const MemoIndexPage({super.key, required this.memoRepository});

  /// メモリポジトリ
  final MemoRepository memoRepository;

  @override
  State<MemoIndexPage> createState() => MemoIndexPageState();
}

@visibleForTesting
class MemoIndexPageState extends State<MemoIndexPage> {
  /// 表示するメモ一覧
  final memos = <Memo>[];

  ///
  @override
  void initState() {
    super.initState();

    /// メモ一覧を監視して変化があれば画面を更新する
    widget.memoRepository.memoStream.listen(_refresh);

    // メモ一覧を取得して画面を更新する
    () async {
      _refresh(await widget.memoRepository.findMemos());
    }();
  }

  /// メモ一覧画面を更新する
  void _refresh(List<Memo> memos) {
    if (!mounted) {
      return;
    }

    setState(() {
      this.memos
        ..clear()
        ..addAll(memos);
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メモ')),

      ///

      body: ListView.builder(
        itemBuilder: (context, index) {
          final memo = memos[index];

          final category = memo.category.value;

          return ListTile(
            // タップされたらメモ更新ダイアログを表示する
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => MemoUpsertDialog(
                widget.memoRepository,
                memo: memo,
              ),
              barrierDismissible: false,
            ),
            title: Text(memo.content),
            subtitle: Text(category?.name ?? ''),
            // 削除ボタン押下されたらメモを即削除する
            trailing: IconButton(
              onPressed: () => widget.memoRepository.deleteMemo(memo),
              icon: const Icon(Icons.close),
            ),
          );
        },
        itemCount: memos.length,
      ),

      ///

      floatingActionButton: FloatingActionButton(
        // メモ追加ダイアログを表示する
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => MemoUpsertDialog(widget.memoRepository),
          barrierDismissible: false,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
