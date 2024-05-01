import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:collection';

@immutable
class Person {
  final String name;
  final int age;
  final String uuid;

  Person({required this.name, required this.age, String? uuid})
      : uuid = uuid ?? const Uuid().v4();

  Person updated([String? name, int? age]) =>
      Person(name: name ?? this.name, age: age ?? this.age);

  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  String get displayName => '$name is ($age years old)';

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() => 'Person(name: $name, age: $age, uuid:$uuid)';
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [Person(name: "Srikanta", age: 23, uuid: "5")];

  int get count => _people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person person) {
    _people.add(person);
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPerson) {
    final index = _people.indexOf(updatedPerson);
    // _people.removeAt(index);
    // _people.insert(index, updatedPerson);
    final oldPerson = _people[index];
    if (oldPerson.name != updatedPerson.name ||
        oldPerson.age != updatedPerson.age) {
      _people[index] = oldPerson.updated(updatedPerson.name, updatedPerson.age);
      notifyListeners();
    }
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();
final peopleProvider = ChangeNotifierProvider.autoDispose((ref) => DataModel());

class CreateEdit extends ConsumerWidget {
  const CreateEdit({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).hoverColor,
        onPressed: (){
          createOrUpdatePersonDialog(context,ref);
        },
        child:const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).hoverColor,
        title: const Text("Change Notifier Provider"),
        centerTitle: true,
      ),
      body: Consumer(
        builder: (context,ref,child){
          final dataModel = ref.watch(peopleProvider);
          return ListView.builder(
              itemCount: dataModel._people.length,
            itemBuilder: (context, index) {
              final person=dataModel.people[index];
              return ListTile(
                trailing: IconButton(onPressed: (){
                  dataModel.remove(person);
                  }, icon:const Icon(Icons.delete)),
                onTap: () => createOrUpdatePersonDialog(context,ref,person),
                title: Text(person.toString()),
              );
        }
          );
        }),
      );
  }

  Future<Person?> createOrUpdatePersonDialog(BuildContext context,WidgetRef ref,
      [Person? existingPerson]) {
    String? name = existingPerson?.name;
    int? age = existingPerson?.age;
    nameController.text = name ?? '';
    ageController.text = age != null ? age.toString() : '';
    return showDialog<Person?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(onPressed: (){
              Navigator.of(context).pop();
            }, child:const Text("Cancel")),
            TextButton(onPressed: (){
              if(existingPerson!=null&&age!=null&&name!=null) {
                ref.read(peopleProvider).update(Person(name: name!, age: age!));
                Navigator.of(context).pop();
              } else if(age!=null||name!=null){
                ref.read(peopleProvider).add(Person(name: name!, age: age!));
                Navigator.of(context).pop();
              }else{
                Navigator.of(context).pop(
                  // "hi" // pass object to return and pop context
                );
              }
            }, child: age!=null&&name!=null?const Text("Update"):const Text("Save")),
          ],
          title: existingPerson != null
              ? const Text("Update a Person")
              : const Text("Create a Person"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                onChanged: (val) {
                  name = val;
                },
                decoration:
                    const InputDecoration(labelText: "Enter your name bro..."),
              ),
              TextField(
                controller: ageController,
                onChanged: (val) => age = int.tryParse(val),
                decoration:
                    const InputDecoration(labelText: "Enter your age bro..."),
              ),
            ],
          ),
        );
      },
    );
  }
}
