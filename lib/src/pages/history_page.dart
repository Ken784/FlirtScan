import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../widgets/navigation/page_header.dart';
import '../widgets/navigation/bottom_nav.dart';
import '../widgets/cards/list_entry_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static const String route = '/history';

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _navIndex = 1;

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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s20, 0, AppSpacing.s20, 120),
            children: const [
              PageHeader(title: '分析記錄', leading: Icon(Icons.inbox_outlined)),
              SizedBox(height: AppSpacing.s16),
              ListEntryCard(partnerName: 'Fiona Lee', scoreText: '9/10', summary: '這種若有似無的關心，其實就是喜歡的訊號！'),
              SizedBox(height: AppSpacing.s12),
              ListEntryCard(partnerName: 'Fiona Lee', scoreText: '6/10', summary: '感情漸漸加溫中！'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}






