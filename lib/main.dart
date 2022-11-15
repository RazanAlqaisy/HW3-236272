import 'dart:ui';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'AuthProvider.dart';
import 'loginPage.dart';
import 'CloudFirestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
              create: (context) => AuthProvider.instance(),
              child: const MyApp());
        }
        return Container(
          width: 500,
          height: 500,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
          ),
          padding: const EdgeInsets.all(20),
          child: const Center(),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,

        ),
      ),
      home: const Scaffold(body: RandomWords()),
    );
  }
}
class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);
  final snappingSheetController = SnappingSheetController();
  bool _swipeFlag = false;
  double filling = 0.0;
  @override
  Widget build(BuildContext context) {

    return Consumer<AuthProvider>(

      builder: (context, AuthProvider user, _) {
        String? s = user.user?.email;
        String _imageURL = 'https://cdn-icons-png.flaticon.com/512/847/847969.png';
        String? sa = user.user?.email;        return Scaffold(
          appBar: AppBar(
            title: const Text('Startup Name Generator'),
            actions: [
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => _pushSaved(user),
                tooltip: 'Saved Suggestions',
              ),
              user.status == Status.Authenticated
                  ? IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  addData(_saved);
                  user.signOut();
                  setState(() {
                    _saved.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Successfully logged out.')));
                },
                tooltip: 'Logout',
              )
                  : IconButton(
                icon: const Icon(Icons.login),
                onPressed: _loginPage,
                tooltip: 'Login',
              )
            ],
          ),
          body: user.isAuthenticated
              ? SnappingSheet(
              controller: snappingSheetController,
              initialSnappingPosition:
              const SnappingPosition.pixels(positionPixels: 30),
              snappingPositions: [
                _swipeFlag
                    ? const SnappingPosition.pixels(
                  positionPixels: 120,
                  snappingCurve: Curves.easeOutExpo,
                  snappingDuration: Duration(seconds: 1),
                  grabbingContentOffset: GrabbingContentOffset.top,
                )
                    : const SnappingPosition.factor(
                  positionFactor: 0.0,
                  snappingCurve: Curves.easeOutExpo,
                  snappingDuration: Duration(seconds: 1),
                  grabbingContentOffset: GrabbingContentOffset.top,
                )
              ],
              grabbingHeight: 60,
              grabbing: GestureDetector(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText('Welcome back, $s', maxLines: 1),
                            _swipeFlag
                                ? const Icon(
                                Icons.keyboard_arrow_down_rounded)
                                : const Icon(
                                Icons.keyboard_arrow_up_rounded)
                          ])),
                  onTap: () {
                    setState(() {
                      _swipeFlag
                          ? snappingSheetController
                          .setSnappingSheetPosition(30)
                          : snappingSheetController
                          .setSnappingSheetPosition(150);
                      _swipeFlag ? filling = 0.0 : filling = 5.0;
                      _swipeFlag = !_swipeFlag;
                    });
                  }),
             // String _imageURL = 'https://cdn-icons-png.flaticon.com/512/847/847969.png';
              //String? s = user.user?.email;
              sheetBelow: SnappingSheetContent(

                child: Container(

                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    FutureBuilder(
                        future: user.getDLink(),
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          _imageURL = snapshot.data ??
                              'https://cdn-icons-png.flaticon.com/512/847/847969.png';
                          return CircleAvatar(
                              backgroundImage: NetworkImage(_imageURL), radius: 40);
                        }),
                    const SizedBox(width: 20),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AutoSizeText('$sa',
                          style: const TextStyle(fontSize: 20), maxLines: 1),
                      const SizedBox(height: 8),
                      TextButton(
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              fixedSize: const Size(120, 10),
                              backgroundColor: Colors.lightBlue),
                          onPressed: () => _imagePicker(user),
                          child: const AutoSizeText("Change avatar",
                              style: TextStyle(fontSize: 10), maxLines: 1))
                    ])
                  ])),
              ),
              child: Stack(children: [
                _buildSuggestions(),
                if (filling == 5.0)
                  Positioned.fill(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: filling,
                            sigmaY: filling,
                          ),
                          child: Container(color: Colors.transparent)))
              ]))
              : _buildSuggestions(),
        );
      },
    );
  }
 /* Widget _showProfile(AuthProvider user) {
    String _imageURL = 'https://cdn-icons-png.flaticon.com/512/847/847969.png';
    String? s = user.user?.email;

    return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FutureBuilder(
              future: user.getDLink(),
              builder: (context, AsyncSnapshot<String> snapshot) {
                _imageURL = snapshot.data ??
                    'https://cdn-icons-png.flaticon.com/512/847/847969.png';
                return CircleAvatar(
                    backgroundImage: NetworkImage(_imageURL), radius: 40);
              }),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AutoSizeText('$s',
                style: const TextStyle(fontSize: 20), maxLines: 1),
            const SizedBox(height: 8),
            TextButton(
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    fixedSize: const Size(120, 10),
                    backgroundColor: Colors.lightBlue),
                onPressed: () => _imagePicker(user),
                child: const AutoSizeText("Change avatar",
                    style: TextStyle(fontSize: 10), maxLines: 1))
          ])
        ]));
  }
 */

  void _imagePicker(AuthProvider user) async {
    final picker = ImagePicker();
    XFile? pickedImage;

    pickedImage =
    await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);

    if (pickedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No image selected')));
      return;
    }

    File imageFile = File(pickedImage.path);

    // Uploading the selected image
    String? userID = user.user?.uid;
    await FirebaseStorage.instance.ref('$userID/profilePic').putFile(imageFile);
  }
  void _loginPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()))
        .then((value) {
      updateSavedData(_saved);
      addData(_saved);
    });
  }


  void _pushSaved(AuthProvider user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          var tiles = _saved.map(
                (suggName) {
                  String capPair = suggName.asPascalCase;
                  return Dismissible(
                    key: UniqueKey(),
                    confirmDismiss: (direction) async {
                      bool confirmToDelete = await _showAlertDialog(suggName);
                      if (confirmToDelete) {
                        setState(() {
                        _saved.remove(suggName);
                        deleteData(suggName);
                      });
                      }
                      return confirmToDelete;
                    },
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: Row(children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 5),
                        Text('Delete Suggestion', style: TextStyle(color: Colors.white))
                      ]),
                    ),
                    child: ListTile(
                        key: UniqueKey(),
                        title: Text(
                          capPair,
                          style: _biggerFont,
                        )),
                  );
            },
          );

          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(key: UniqueKey(), children: divided),
          );
        },
      ),
    );
  }


  Future<bool> _showAlertDialog(WordPair suggName) async {
    String toDelete = suggName.asPascalCase;
    bool confirmedToDelete = false;
    await showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Delete Suggestion'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  //Text('This is a demo alert dialog.'),
                  Text('Are you sure you want to remove $toDelete ?'),
                  //ColoredBox(color: Colors.red)
                ],
              ),
            ),
          actions: [
            TextButton(onPressed: () {
              setState(() {
                confirmedToDelete =true;
                Navigator.pop(context);
              });
            },
              child: const Text('Yes'),


            ),
            TextButton(onPressed:() {Navigator.of(context).pop();},
                child: const Text('No'))
          ],
          );

        }
    );
    return confirmedToDelete;
  }


  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        updateSavedData(_saved);
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    var alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.star : Icons.star_border,
        color: alreadySaved ? Colors.redAccent : null,
        semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
            deleteData(pair);
          } else {
            _saved.add(pair);
            addData(_saved);
          }
        });
      },
    );
  }
}


