import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Test Drive',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// アプリの状態を定義
// ChangeNotifierは自身の変更に関する通知を行える
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  // currentに新しいランダムなWordPairを代入し、MyAppStateにnotifyListeners()で変更を通知する
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  // buildメソッドは周囲の状況が変化するたびに自動でよびだされる(状態を最新に保つため、どのウィジェットでも定義する必要がある)
  Widget build(BuildContext context) {
    // MyHomePageではMyAppStateをwatchし、アプリの現在の状態に対する変更を追跡する
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      // Columnは子要素を縦に並べるレイアウトウィジェット
      // リファクターからwrap with centerで中央よせ
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 子要素を中央に配置
          children: [
            // 2個目のTextはappState.current（WordPair)の値を表示する
            BigCard(pair: pair),
            SizedBox(height: 20), // SizedBoxは指定したサイズの空白を作る
            ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next')),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      letterSpacing: -1.0,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
