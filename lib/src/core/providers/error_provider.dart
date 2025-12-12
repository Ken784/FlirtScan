import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 錯誤訊息狀態
class ErrorState {
  final String? message;
  final String? title;

  ErrorState({this.message, this.title});

  ErrorState copyWith({String? message, String? title}) {
    return ErrorState(
      message: message ?? this.message,
      title: title ?? this.title,
    );
  }

  bool get hasError => message != null;

  ErrorState clear() => ErrorState(message: null, title: null);
}

/// 錯誤狀態 Notifier
class ErrorNotifier extends StateNotifier<ErrorState> {
  ErrorNotifier() : super(ErrorState());

  /// 顯示錯誤
  void showError(String message, {String? title}) {
    state = ErrorState(message: message, title: title);
  }

  /// 清除錯誤
  void clearError() {
    state = ErrorState();
  }
}

/// 錯誤狀態 Provider
final errorProvider = StateNotifierProvider<ErrorNotifier, ErrorState>((ref) {
  return ErrorNotifier();
});


