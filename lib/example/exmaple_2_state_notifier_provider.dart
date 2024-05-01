import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final counterProvider=StateNotifierProvider<Counter1,int?>((ref) => Counter1());

class Counter extends ConsumerWidget {
  const Counter({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    // final number=ref.watch(counterProvider);
    print("rebuild");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).hoverColor,
        title:Consumer(
          builder: (context,ref,child){
            final displayNum = ref.watch(counterProvider);
            return Text(displayNum.toString()==null.toString()?"Press the button ":displayNum.toString());
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: ref.read(counterProvider.notifier).increment,
            child:const Text('Increment counter')
          ),
        ],
      )
    );
  }
}
extension OptionalInfixAddition<T extends num> on T?
{
  T? operator +(T? other) {
    final shadow = this;
    if (shadow != null) {
      return shadow + (other ?? 0) as T;
    }
    return null;
  }
}


class Counter1 extends StateNotifier<int?>{
  Counter1():super(null);
  void increment()=>state = state == null ?0:state+1;
}