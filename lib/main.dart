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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
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

  // お気に入りのWordPairを保持するリスト(ジェネリクスで型を指定)
  var favorites = <WordPair>[];

  void toggleFavorite() {
    // お気に入りに含まれているかどうかをcontainsで判定
    if (favorites.contains(current)) {
      favorites.remove(current); // 含まれていれば削除
    } else {
      favorites.add(current); // 含まれていなければ追加
    }
    // 変更を通知
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        // SafeAreaは画面の端に表示されるステータスバーなどの領域を考慮してくれる
        // このアプリでは、このウィジェットがNavigationRailを包んで、ナビゲーション ボタンがモバイル ステータスバーなどで隠されるのを防いでいる
        SafeArea(
          child: NavigationRail(
            extended: false, // ラベルを表示するかどうか
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite),
                label: Text('Favorites'),
              ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: GeneratorPage(),
          ),
        ),
      ],
    ));
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  // buildメソッドは周囲の状況が変化するたびに自動でよびだされる(状態を最新に保つため、どのウィジェットでも定義する必要がある)
  Widget build(BuildContext context) {
    // MyHomePageではMyAppStateをwatchし、アプリの現在の状態に対する変更を追跡する
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    final isFavorite = appState.favorites.contains(pair);
    final favoriteIcon = isFavorite ? Icons.favorite : Icons.favorite_border;
    final likeOrUnlike = isFavorite ? Text('Unlike') : Text('Like');

    return Center(
      // Columnは子要素を縦に並べるレイアウトウィジェット
      // リファクターからwrap with centerで中央よせ
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 子要素を中央に配置

        children: [
          // 2個目のTextはappState.current（WordPair)の値を表示する
          BigCard(pair: pair),
          SizedBox(height: 20), // SizedBoxは指定したサイズの空白を作る
          Row(
            mainAxisSize: MainAxisSize.min, // Rowの幅を子要素の合計にする
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  // favoriteに含まれているかどうか判定し、表示を出し分ける
                  icon: Icon(favoriteIcon),
                  label: likeOrUnlike),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next')),
            ],
          ),
        ],
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
