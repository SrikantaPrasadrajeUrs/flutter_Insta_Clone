import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// read and write[update]
final currentCityProvider = StateProvider<City?>((ref) => null);
// reads
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unknownWeatherEmoji;
  }
});
const unknownWeatherEmoji = '🕵️‍♂️';

class Example3 extends ConsumerWidget {
  const Example3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).hoverColor,
        title: const Text("Weather"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          weather.when(
              data: (data){
                return Text(data,style: const TextStyle(fontSize: 45),);
              },
              error: (error,stackTrace){
                return Text(error.toString());
              },
              loading: (){
                return const CircularProgressIndicator();
              }
          ),
          Expanded(
            child: ListView.builder(
                itemCount: City.values.length,
                itemBuilder: (context, index) {
                  final city = City.values[index];
                  final isSelected = city == ref.watch(currentCityProvider);
                  return ListTile(
                    title: Text(city.toString()),
                    trailing: isSelected ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
                    onTap: () {
                      ref
                          .read(currentCityProvider.notifier)
                          .update((state) => city);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

typedef WeatherEmoji = String;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(const Duration(seconds: 0), () {
    return {
          City.stockholm: '♨️',
          City.paris: '⛈️',
          City.tokyo: '☁️',
        }[city] ??
        '🔥';
  });
}

enum City {
  stockholm,
  paris,
  tokyo,
}
