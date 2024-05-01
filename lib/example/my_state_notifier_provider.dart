import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavorite;
  const Film(
      {required this.id,
      required this.title,
      required this.description,
      required this.isFavorite});

  Film copy({required bool isFavorite}) {
    return Film(
        id: id.toString(),
        title: title,
        description: description,
        isFavorite: isFavorite);
  }

  @override
  String toString() => 'Film(id: $id, '
      'title: $title, '
      'description: $description,'
      'isFavorite: $isFavorite)';

  @override
  bool operator ==(covariant Film film) {
    return this == film;
  }

  ///Object.hashAll is a static method used to combine the hash codes of multiple objects into a single hash code.
  ///It's a convenient way to create a unique identifier based on the combination
  ///of values in a collection or set of objects.
  @override
  int get hashCode => Object.hashAll([id, isFavorite]);
}

List<Film> allFilms = const [
  Film(
    id: '1',
    title: 'Inception',
    description:
        'A thief who enters the dreams of others to steal their secrets.',
    isFavorite: true,
  ),
  Film(
    id: '2',
    title: 'The Shawshank Redemption',
    description:
        'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
    isFavorite: false,
  ),
  Film(
    id: '3',
    title: 'The Godfather',
    description:
        'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
    isFavorite: true,
  ),
  Film(
    id: '4',
    title: 'The Dark Knight',
    description:
        'When the menace known as The Joker emerges from his mysterious past, he wreaks havoc and chaos on the people of Gotham.',
    isFavorite: false,
  ),
  Film(
    id: '5',
    title: 'Pulp Fiction',
    description:
        'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.',
    isFavorite: true,
  ),
  Film(
    id: '6',
    title: 'Forrest Gump',
    description:
        'The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold from the perspective of an Alabama man with an IQ of 75, whose only desire is to be reunited with his childhood sweetheart.',
    isFavorite: false,
  ),
  Film(
    id: '7',
    title: 'Fight Club',
    description:
        'An insomniac office worker and a devil-may-care soapmaker form an underground fight club that evolves into something much, much more.',
    isFavorite: true,
  ),
  Film(
    id: '8',
    title: 'The Matrix',
    description:
        'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.',
    isFavorite: false,
  ),
  Film(
    id: '9',
    title: 'Goodfellas',
    description:
        'The story of Henry Hill and his life in the mob, covering his relationship with his wife Karen Hill and his mob partners Jimmy Conway and Tommy DeVito in the Italian-American crime syndicate.',
    isFavorite: true,
  ),
  Film(
    id: '10',
    title: 'The Lord of the Rings: The Fellowship of the Ring',
    description:
        'A meek Hobbit from the Shire and eight companions set out on a journey to destroy the powerful One Ring and save Middle-earth from the Dark Lord Sauron.',
    isFavorite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);
  void update(Film film, bool isFavorite) {
    state = state
        .map((thisFilm) => thisFilm.id == film.id
            ? thisFilm.copy(isFavorite: !isFavorite)
            : thisFilm)
        .toList();
  }

  void toggleLists(
    String condition,
  ) {
    bool? value;
    if (condition == 'all') {
      value = null;
    } else if (condition == 'favorite') {
      value = true;
    } else if (condition == 'notFavorite') {
      value = false;
    }
    if (value == null) {
      state = allFilms;
    } else {
      state = allFilms.where((films) => films.isFavorite == value).toList();
    }
  }
}

enum FavoriteStatus {
  all,
  favorite,
  notFavorite;
}

// to access status on changed
final favoriteStatusProvider = StateProvider((ref) => FavoriteStatus.all);

final allFilmsProvider =
    StateNotifierProvider<FilmsNotifier, List<Film>>((ref) => FilmsNotifier());
// favorite films
final favoriteFilm = StateProvider(
    (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavorite));
// not f f
final notFavoriteFilm = StateProvider(
    (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavorite));

class FavoriteMovie extends StatelessWidget {
  const FavoriteMovie({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Theme.of(context).hoverColor,
        title: const Text("State Notifier Provider"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const FilterWidget(),
          Consumer(builder: (context, ref, child) {
            final favoriteStatus = ref.watch(favoriteStatusProvider);
            switch (favoriteStatus) {
              case FavoriteStatus.all:
                return FilmsList(myProvider: allFilmsProvider);
              case FavoriteStatus.favorite:
                return FilmsList(myProvider: favoriteFilm);
              case FavoriteStatus.notFavorite:
                return FilmsList(myProvider: notFavoriteFilm);
              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          }),
        ],
      ),
    );
  }
}

class FilmsList extends ConsumerWidget {
  final AlwaysAliveProviderListenable<Iterable<Film>> myProvider;
  const FilmsList({super.key, required this.myProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(myProvider);
    return Expanded(
      child: ListView.builder(
          itemCount: films.length,
          itemBuilder: (context, index) {
            final film = films.elementAt(index);
            final favoriteIcon = film.isFavorite
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border);
            return ListTile(
              trailing: IconButton(
                icon: favoriteIcon,
                onPressed: () {
                  ref
                      .read(allFilmsProvider.notifier)
                      .update(film, film.isFavorite);
                },
              ),
              title: Text(film.title),
              subtitle: Text(film.description),
            );
          }),
    );
  }
  // Widget build(BuildContext context, WidgetRef ref) {
  //   return Scaffold(
  //     floatingActionButton: FloatingActionButton(
  //       backgroundColor: Theme.of(context).hoverColor,
  //       onPressed: () {},
  //       child: const Icon(Icons.add),
  //     ),
  //     appBar: AppBar(
  //       elevation: 10,
  //       backgroundColor: Theme.of(context).hoverColor,
  //       title: const Text("State Notifier Provider"),
  //       centerTitle: true,
  //     ),
  //     body: Consumer(
  //       builder: (context, ref, child) {
  //         List<Film> films = ref.watch(allFilmsProvider);
  //         return Column(
  //           children: [
  //             Expanded(
  //               flex: 0,
  //               child: DropdownButtonFormField(
  //                 value: 0,
  //                 items: [
  //                   DropdownMenuItem(
  //                       value: 0,
  //                       child: Text(FavoriteStatus.all.name.toString())),
  //                   DropdownMenuItem(
  //                       value: 1,
  //                       child: Text(FavoriteStatus.favorite.toString())),
  //                   DropdownMenuItem(
  //                       value: 2,
  //                       child: Text(FavoriteStatus.notFavorite.toString())),
  //                 ],
  //                 onChanged: (value) {
  //                   if (value == 0) {
  //                     ref.read(allFilmsProvider.notifier).toggleLists("all");
  //                   } else if (value == 1) {
  //                     ref
  //                         .read(allFilmsProvider.notifier)
  //                         .toggleLists("favorite");
  //                   } else {
  //                     ref
  //                         .read(allFilmsProvider.notifier)
  //                         .toggleLists("notFavorite");
  //                   }
  //                 },
  //               ),
  //             ),
  //             Flexible(
  //               child: ListView.builder(
  //                   itemCount: films.length,
  //                   itemBuilder: (context, index) {
  //                     return ListTile(
  //                       title: Text(films[index].title),
  //                     );
  //                   }),
  //             )
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return DropdownButton(
            value: ref.watch(favoriteStatusProvider),
            items: FavoriteStatus.values
                .map((fs) => DropdownMenuItem(value: fs, child: Text(fs.name)))
                .toList(),
            onChanged: (fs) {
              ref.read(favoriteStatusProvider.notifier).update((state) => fs!);
            });
      },
    );
  }
}
