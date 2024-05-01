import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<DateTime> currentDate=Provider((ref) => DateTime.now());

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final date=ref.watch(currentDate);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).hoverColor,
        title:const Text("HomePage"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          date.toIso8601String(),style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
