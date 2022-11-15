
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/AuthProvider.dart';

void deleteData(WordPair pair) { //use to delete suggestions from favorites
  final user = AuthProvider.instance();
  if (user.isAuthenticated) {
    FirebaseFirestore.instance
        .collection("userSaved")
        .doc(user.user!.uid.toString())
        .collection("favorites")
        .doc(pair.toString())
        .delete();
  }
}

void addData(_saved) { //used to add suggestions to favorites
  final user = AuthProvider.instance();
  if (user.isAuthenticated) {
    _saved.forEach((sugg) async {
      await FirebaseFirestore.instance
          .collection("userSaved")
          .doc(user.user!.uid.toString())
          .collection("favorites")
          .doc(sugg.toString())
          .set({"first": sugg.first, "second": sugg.second});
    });
  }
}
void updateSavedData(_saved) async { //use this to update favorites when user is in
  final user = AuthProvider.instance();
  if (user.isAuthenticated) {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("userSaved")
        .doc(user.user?.uid.toString())
        .collection("favorites")
        .get();
    List<QueryDocumentSnapshot> favs = snapshot.docs;
    Set<WordPair> addToSaved = new HashSet();
    favs.forEach((e) => {addToSaved.add(WordPair(e.get('first'), e.get('second')))});
    _saved.addAll(addToSaved);
  }
}