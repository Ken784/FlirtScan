import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/models/analysis_result.dart';
import '../core/providers/analysis_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/icons/app_icon_widgets.dart';
import '../services/storage_service.dart';
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
  final StorageService _storageService = StorageService();
  int _navIndex = 1;
  bool _isLoading = true;
  List<AnalysisHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final results = await _storageService.getHistory();
    if (!mounted) return;
    setState(() {
      _history = results;
      _isLoading = false;
    });
  }

  /// 根據 ID 刪除記錄（更可靠，不依賴索引）
  Future<void> _deleteById(String id) async {
    // 先從 UI 中移除（樂觀更新），提供即時反饋
    // 這樣即使儲存操作有延遲，用戶也能立即看到反饋
    bool wasInList = false;
    if (mounted) {
      setState(() {
        wasInList = _history.any((entry) => entry.result.id == id);
        _history.removeWhere((entry) => entry.result.id == id);
      });
    }
    
    // 然後從儲存中刪除，確保資料已從持久化儲存中移除
    // 這樣即使頁面重新構建，資料也不會再出現
    try {
      await _storageService.deleteAnalysis(id);
    } catch (e) {
      // 如果刪除失敗且記錄原本在列表中，重新載入以確保一致性
      if (mounted && wasInList) {
        _loadHistory();
      }
    }
  }


  void _onItemTap(AnalysisHistoryEntry entry) {
    // 將歷史結果寫入 analysisProvider，讓 ResultPage / ResultSentencePage 可共用
    ref.read(analysisProvider.notifier).loadFromHistory(
          entry.result,
          imageBase64: entry.imageBase64,
        );
    context.push(ResultPage.route);
  }

  String _displayName(AnalysisResult result) {
    final name = result.partnerName.trim();
    if (name.isEmpty || name == '對方') {
      return '未知對象';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _history.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20, 0, AppSpacing.s20, 120),
                      children: [
                        PageHeader(
                          title: '分析記錄',
                          leading: AppIconWidgets.inbox(),
                        ),
                        const SizedBox(height: AppSpacing.s32),
                        const Center(
                          child: Text(
                            '目前還沒有分析紀錄',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20, 0, AppSpacing.s20, 120),
                      itemCount: _history.length + 2,
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

                        if (index == _history.length + 1) {
                          return const SizedBox(height: AppSpacing.s16);
                        }

                        final itemIndex = index - 1;
                        final entry = _history[itemIndex];
                        final result = entry.result;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: itemIndex == _history.length - 1
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
                              scoreText:
                                  '${result.totalScore.round()}/10',
                              summary: result.toneInsight,
                              imageBase64: entry.imageBase64,
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

