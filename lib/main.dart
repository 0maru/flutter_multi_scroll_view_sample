import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

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
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Text('スクロールしても表示し続ける')),
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

class _NestedScrollView extends StatelessWidget {
  const _NestedScrollView({
    super.key,
    required this.headers,
    required this.stackChildren,
  });

  final List<Widget> headers;
  final List<Widget> stackChildren;

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return headers;
      },
      body: Stack(
        children: stackChildren,
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 10,
      itemBuilder: (_, i) {
        return _InfinityScrollView(pageIndex: i);
      },
    );
  }
}

class _InfinityScrollView extends StatelessWidget {
  const _InfinityScrollView({
    super.key,
    required this.pageIndex,
  });

  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: ScrollController(),
      itemCount: 100,
      itemBuilder: (_, i) {
        return ColoredBox(
          color: i % 2 == 0 ? Colors.white : Colors.black12,
          child: ListTile(
            title: Text('pageIndex: $pageIndex, index: $i'),
          ),
        );
      },
    );
  }
}
