import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/analysis_result.dart';
import '../core/providers/analysis_provider.dart';
import '../core/providers/history_provider.dart';
import '../services/storage_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/icons/app_icon_widgets.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/navigation/bottom_nav.dart';
import '../widgets/cards/list_entry_card.dart';
import 'home_page.dart';
import 'result_page.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  static const String route = '/history';

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  int _navIndex = 1;
  bool _shouldReloadOnNextBuild = false;

  @override
  void initState() {
    super.initState();
    // 歷史記錄由 historyProvider 管理，不需要手動載入
  }

  /// 根據 ID 刪除記錄
  Future<void> _deleteById(String id) async {
    try {
      await ref.read(historyProvider.notifier).deleteById(id);
    } catch (e) {
      // 刪除失敗時，Provider 會自動重新載入以確保一致性
      // 這裡可以選擇顯示錯誤訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('刪除失敗：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTap(AnalysisHistoryEntry entry) {
    // 將歷史結果寫入 analysisProvider，讓 ResultPage / ResultSentencePage 可共用
    ref.read(analysisProvider.notifier).loadFromHistory(
          entry.result,
          imageBase64: entry.imageBase64,
        );
    // 當從 ResultPage 返回時，重新載入數據以反映可能的刪除操作
    context.push(ResultPage.route).then((_) {
      // 從 ResultPage 返回，設置標記以在下次 build 時重新載入
      if (mounted) {
        setState(() {
          _shouldReloadOnNextBuild = true;
        });
      }
    });
  }

  String _displayName(AnalysisResult result) {
    final name = result.partnerName.trim();
    if (name.isEmpty || name == '對方') {
      return '未知對象';
    }
    return name;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 監聽歷史記錄狀態
    final historyState = ref.watch(historyProvider);
    final history = historyState.entries;

    // 監聽分析狀態，當分析完成時自動重新載入歷史記錄
    final analysisState = ref.watch(analysisProvider);
    ref.listen<AnalysisState>(analysisProvider, (previous, next) {
      // 情況1：分析剛完成
      if (previous?.isCompleted != true && next.isCompleted && next.result != null) {
        // 分析完成，延遲一小段時間後重新載入，確保保存操作已完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(historyProvider.notifier).reload();
          }
        });
      }
      // 情況2：進階分析被解鎖（result 的 isAdvancedUnlocked 從 false 變為 true）
      if (previous?.result != null && next.result != null &&
          previous!.result!.id == next.result!.id &&
          !previous.result!.isAdvancedUnlocked &&
          next.result!.isAdvancedUnlocked) {
        // 進階分析解鎖，延遲一小段時間後重新載入，確保保存操作已完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(historyProvider.notifier).reload();
          }
        });
      }
    });

    // 檢查是否需要重新載入數據（從 ResultPage 返回時）
    if (_shouldReloadOnNextBuild) {
      _shouldReloadOnNextBuild = false;
      // 在下一幀重新載入，避免在 build 期間修改狀態
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(historyProvider.notifier).reload();
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgGradientTop, AppColors.bgGradientBottom],
          ),
        ),
        child: SafeArea(
          child: historyState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : history.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20, 0, AppSpacing.s20, 120),
                      children: [
                        PageHeader(
                          title: '分析記錄',
                          leading: AppIconWidgets.inbox(),
                        ),
                        const SizedBox(height: AppSpacing.s32),
                        Center(
                          child: Text(
                            '沒有儲存的紀錄',
                            style: AppTextStyles.body3Semi
                                .copyWith(color: AppColors.textBlack80),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20, 0, AppSpacing.s20, 120),
                      itemCount: history.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.s16),
                            child: PageHeader(
                              title: '分析記錄',
                              leading: AppIconWidgets.inbox(),
                            ),
                          );
                        }

                        if (index == history.length + 1) {
                          return const SizedBox(height: AppSpacing.s16);
                        }

                        final itemIndex = index - 1;
                        final entry = history[itemIndex];
                        final result = entry.result;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: itemIndex == history.length - 1
                                ? 0
                                : AppSpacing.s12,
                          ),
                          child: Dismissible(
                            key: ValueKey(result.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s20),
                              color: Colors.redAccent,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              _deleteById(result.id);
                            },
                            child: ListEntryCard(
                              partnerName: _displayName(result),
                              scoreText: '${result.totalScore.round()}',
                              summary: result.toneInsight,
                              dateText: _formatDate(result.createdAt),
                              onTap: () => _onItemTap(entry),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == _navIndex) return;
          setState(() => _navIndex = i);
          if (i == 0) {
            context.go(HomePage.route);
          } else {
            context.go(HistoryPage.route);
          }
        },
      ),
    );
  }
}
