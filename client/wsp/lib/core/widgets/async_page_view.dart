import 'package:flutter/material.dart';
import 'package:wsp/core/widgets/page_error_view.dart';

class AsyncPageView<T> extends StatelessWidget {
  const AsyncPageView({
    super.key,
    required this.future,
    required this.onRefresh,
    required this.builder,
    this.errorTitle,
  });

  final Future<T> future;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T data) builder;
  final String? errorTitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return PageErrorView(
              title: errorTitle,
              message: snapshot.error.toString(),
              onRetry: onRefresh,
            );
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: builder(context, snapshot.requireData),
          );
        },
      ),
    );
  }
}
