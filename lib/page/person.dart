import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devfest/data/database.dart';
import 'package:devfest/model/person.dart';
import 'package:devfest/widget/person.dart';
import 'package:flutter/material.dart';

enum PersonType { organizer, speaker }

class PersonPage extends StatelessWidget {
  final PersonType personType;
  PersonPage({@required this.personType, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stream = personType == PersonType.speaker
        ? Database.firebase()
            .collection("person")
            .where("job", isLessThanOrEqualTo: 2)
            .orderBy("job", descending: true)
            .orderBy("firstName")
            .snapshots()
        : Database.firebase()
            .collection("person")
            .where("job", isGreaterThanOrEqualTo: 2)
            .orderBy("job", descending: false)
            .orderBy("firstName")
            .snapshots();

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Person> personsList = snapshot.data.documents
              .map((data) => Person.fromFirestore(data))
              .toList();

          return _buildList(personsList, context);
        },
      ),
    );
  }

  Widget _buildList(List<Person> persons, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.86,
        children: List.generate(
          persons.length,
          (i) => PersonWidget(
            accentColor:
                personType == PersonType.speaker ? Colors.green : Colors.red,
            person: persons[i],
          ),
        ),
      ),
    );
  }
}
