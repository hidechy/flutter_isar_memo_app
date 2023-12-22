import 'package:flutter/material.dart';

import 'collections/category.dart';
import 'collections/memo.dart';
import 'memo_repository.dart';

/// メモ登録/更新ダイアログ
class MemoUpsertDialog extends StatefulWidget {
  const MemoUpsertDialog(
    this.memoRepository, {
    super.key,
    this.memo,
  });

  /// メモリポジトリ
  final MemoRepository memoRepository;

  /// 更新するメモ（登録時はnull）
  final Memo? memo;

  @override
  State<MemoUpsertDialog> createState() => MemoUpsertDialogState();
}

@visibleForTesting
class MemoUpsertDialogState extends State<MemoUpsertDialog> {
  /// 表示するカテゴリ一覧
  final categories = <Category>[];

  /// 選択中のカテゴリ
  Category? _selectedCategory;

  Category? get selectedCategory => _selectedCategory;

  /// 入力中のメモコンテンツ
  final _textController = TextEditingController();

  String get content => _textController.text;

  @override
  void initState() {
    super.initState();

    () async {
      // カテゴリ一覧を取得する
      categories.addAll(await widget.memoRepository.findCategories());

      // 初期値を設定する
      _selectedCategory = categories.firstWhere(
        (category) => category.id == widget.memo?.category.value?.id,
        orElse: () => categories.first,
      );
      _textController.text = widget.memo?.content ?? '';

      // 再描画する
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            // カテゴリはドロップボタンで選択する
            DropdownButton<Category>(
              value: _selectedCategory,
              items: categories
                  .map(
                    (category) => DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.name),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              isExpanded: true,
            ),
            TextField(
              controller: _textController,
              onChanged: (_) {
                // 「保存」ボタンの活性化/非活性化を更新するために画面更新する
                setState(() {});
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          // 入力中のメモコンテンツが1文字以上あるときだけ「保存」ボタンを活性化する
          onPressed: content.isNotEmpty
              ? () async {
                  final memo = widget.memo;
                  if (memo == null) {
                    // 登録処理
                    await widget.memoRepository.addMemo(
                      category: _selectedCategory!,
                      content: content,
                    );
                  } else {
                    // 更新処理
                    await widget.memoRepository.updateMemo(
                      memo: memo,
                      category: _selectedCategory!,
                      content: content,
                    );
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
          child: const Text('保存'),
        ),
      ],
    );
  }
}
