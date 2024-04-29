import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

@riverpod
List<GlobalKey<NestedScrollViewState>> globalKeys(GlobalKeysRef ref) {
  return [
    GlobalKey<NestedScrollViewState>(debugLabel: '0'),
    GlobalKey<NestedScrollViewState>(debugLabel: '1'),
    GlobalKey<NestedScrollViewState>(debugLabel: '2'),
    GlobalKey<NestedScrollViewState>(debugLabel: '3'),
    GlobalKey<NestedScrollViewState>(debugLabel: '4'),
    GlobalKey<NestedScrollViewState>(debugLabel: '5'),
    GlobalKey<NestedScrollViewState>(debugLabel: '6'),
  ];
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiScrollViewSample',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MultiScrollViewSample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _NestedScrollView(
              headers: [
                _FixedAppBar(),
                _HideAppBar(),
                _HideAppBar(),
              ],
              stackChildren: [
                _PageView(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedAppBar extends StatelessWidget {
  const _FixedAppBar();

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      toolbarHeight: 54,
      pinned: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      flexibleSpace: ColoredBox(
        color: Colors.red,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Text('スクロールしても表示し続ける'),
        ),
      ),
    );
  }
}

class _HideAppBar extends StatelessWidget {
  const _HideAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 46,
      pinned: true,
      floating: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border.all(color: Colors.black),
        ),
        child: const SizedBox(
          height: 46,
          child: Center(
            child: Text('スクロールしたら隠れる'),
          ),
        ),
      ),
    );
  }
}

class _NestedScrollView extends StatefulHookConsumerWidget {
  const _NestedScrollView({
    required this.headers,
    required this.stackChildren,
  });

  final List<Widget> headers;
  final List<Widget> stackChildren;

  @override
  ConsumerState<_NestedScrollView> createState() => _NestedScrollViewState();
}

class _NestedScrollViewState extends ConsumerState<_NestedScrollView> {
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      key: ref.watch(globalKeysProvider)[ref.watch(pageIndexProvider)],
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return widget.headers;
      },
      body: Stack(
        children: widget.stackChildren,
      ),
    );
  }
}

class _PageView extends HookConsumerWidget {
  const _PageView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageView.builder(
      itemCount: ref.watch(globalKeysProvider).length,
      onPageChanged: (index) {
        ref.read(pageIndexProvider.notifier).update((state) => index);
      },
      itemBuilder: (_, i) {
        return _InfinityScrollView(pageIndex: i);
      },
    );
  }
}

class _InfinityScrollView extends StatefulHookConsumerWidget {
  const _InfinityScrollView({
    required this.pageIndex,
  });

  final int pageIndex;

  @override
  ConsumerState<_InfinityScrollView> createState() => _InfinityScrollViewState();
}

class _InfinityScrollViewState extends ConsumerState<_InfinityScrollView>
    with AutomaticKeepAliveClientMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // NestedScrollViewのスクロールを監視
    // ただしPageViewでListViweを切り替えてもスクロール位置はNestedScrollViewのスクロール位置になる
    // 個別にScrollControllerを管理したい場合には使えない
    ref
        .watch(globalKeysProvider)[ref.watch(pageIndexProvider)]
        .currentState
        ?.innerController
        .addListener(() {
      debugPrint(
        'index: ${widget.pageIndex}, pixels: ${globalKey.currentState?.innerController.position.pixels}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (_, i) {
        return ColoredBox(
          color: i % 2 == 0 ? Colors.white : Colors.black12,
          child: ListTile(
            title: Text('pageIndex: ${widget.pageIndex}, index: $i'),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
