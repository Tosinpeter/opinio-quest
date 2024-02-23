import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_provider.freezed.dart';

@freezed
class HomePageState with _$HomePageState {
  const factory HomePageState({
    @Default(true) bool isLoading,
  }) = _HomePageState;

  const HomePageState._();
}

class HomeController extends StateNotifier<HomePageState> {
  HomeController() : super(const HomePageState());

  final controller = Completer<WebViewController>();

  set isLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  bool get isLoading => state.isLoading;
}

final homePageProvider = StateNotifierProvider<HomeController, HomePageState>((ref) => HomeController());
