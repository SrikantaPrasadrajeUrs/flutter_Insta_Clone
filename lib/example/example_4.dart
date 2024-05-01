import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const names=[
  'srikanta',
  'prasad',
  'raje',
  'urs',
  'what',
  'when',
  'AsyncValue',
  'Stream Provider'
];
final tickerProvider=StreamProvider((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) {
     return i+1;
  });
});

final namesProvider=StreamProvider((ref){
  return ref.watch(tickerProvider.stream).map((count) => names.getRange(0,count));
  // testing git
});

class Example4 extends ConsumerWidget {
  const Example4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names=ref.watch(namesProvider);

    // print(namesAccessor.);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).hoverColor,
        title: const Text("Stream Provider"),
        centerTitle: true,
      ),
      body: names.when(
          data: (data){
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context,index){
                  return ListTile(
                    title: Text(data.elementAt(index)),
                  );
                }
            );
          },
          error: (error,stackTrace){
            return const Text("End of the List");
          },
          loading: (){
            return const CircularProgressIndicator();
          }
      ),
    );
  }
}


