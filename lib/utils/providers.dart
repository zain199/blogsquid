import 'package:hooks_riverpod/hooks_riverpod.dart';

final postsProvider = StateProvider<List>((ref) => []);
final latestpostsProvider = StateProvider<List>((ref) => []);
final bookmarksProvider = StateProvider<List>((ref) => []);
final categoryProvider = StateProvider<List>((ref) => []);
final subCategoryProvider = StateProvider<List>((ref) => []);
final pagesProvider = StateProvider<List>((ref) => []);
final colorProvider = StateProvider<String>((ref) => 'light');
final accountProvider = StateProvider<Map>((ref) => {});
final dataSavingModeProvider = StateProvider<bool>((ref) => false);
final offlineModeProvider = StateProvider<bool>((ref) => false);
final userTokenProvider = StateProvider<String>((ref) => '');
