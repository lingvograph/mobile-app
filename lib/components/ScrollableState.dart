import 'package:flutter/material.dart';
import 'package:memoapp/model.dart';

typedef FetchPageFn<T> = Future<ListResult<T>> Function(int offset, int limit);
typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);
typedef SetStateFn = void Function(VoidCallback fn);

class ScrollableState<T> {
  FetchPageFn<T> fetch;
  ItemWidgetBuilder itemBuilder;
  SetStateFn setState;

  List<T> items = new List();
  int total;
  ScrollController scrollController = new ScrollController();

  ScrollableState(this.fetch, this.itemBuilder, this.setState);

  void init() {
    fetchPage();

    scrollController.addListener(() {
      var atBottom = scrollController.position.pixels ==
          scrollController.position.maxScrollExtent;
      if (atBottom && items.length < total) {
        fetchPage();
      }
    });
  }

  void dispose() {
    scrollController.dispose();
  }

  fetchPage() async {
    var result = await fetch(items.length, 10);
    setState(() {
      total = result.total;
      items.addAll(result.items);
    });
  }

  Widget build(BuildContext context) {
    return new ListView.builder(
        controller: scrollController,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return this.itemBuilder(context, items[index]);
        });
  }
}
