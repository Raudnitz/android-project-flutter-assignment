import 'dart:ui';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hello_me/login_page.dart';
import 'package:hello_me/user_repository.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
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
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserRepository>(
        create: (_) => UserRepository.instance(),
        child: Consumer<UserRepository>(
            builder: (context, UserRepository user, _) {
          return MaterialApp(
            title: 'Startup Name Generator',
            theme: ThemeData(
              primaryColor: Colors.redAccent,
            ),
            home: RandomWords(user),
          );
        }));
  }
}

class RandomWords extends StatefulWidget {
  final UserRepository user;

  RandomWords(UserRepository user) : user = user;

  @override
  _RandomWordsState createState() => _RandomWordsState(user);
}

class _RandomWordsState extends State<RandomWords> {
  final UserRepository user;
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  var _controller = SnappingSheetController();
  //String url = 'https://thispersondoesnotexist.com/image';

  _RandomWordsState(UserRepository user) : user = user;

  // uploadPic(File _image1) async {
  //   Future<String> url;
  //   Reference ref = _storage.ref().child("image1" + DateTime.now().toString());
  //   UploadTask uploadTask = ref.putFile(_image1);
  //   uploadTask.whenComplete(() {
  //     url = ref.getDownloadURL();
  //   }).catchError((onError) {
  //     print(onError);
  //   });
  //   return url;
  // }

  List<Widget> _getDividedTiles(context) {
    var tiles = user.saved.map(
      (String pair) {
        return Builder(
          builder: (context) => ListTile(
              title: Text(
                pair,
                style: _biggerFont,
              ),
              trailing: IconButton( icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: (){
                  setState(() {
                  _buildRow(pair);
                  user.deletePair(pair);
                  });
                  // Scaffold.of(context).showSnackBar(snackBar);
                  }
              ),
          ),
        );
      },
    );
    return ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
  }



  Widget _buildSaved() {
    return Scaffold(
        appBar: AppBar(
          title: Text('Saved Suggestions'),
        ),
        body: Consumer<UserRepository>(
          builder: (context, userRepository, _) =>
              ListView(children: _getDividedTiles(context)),
        ));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return _buildSaved();
        },
      ),
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => LoginPage()),
    );
  }

  void _pushLogout() {
    user.saved.clear();
    user.signOut();
  }

  Widget homePage() {
    if (user.status == Status.Authenticated) {
      return Scaffold(
        body: SnappingSheet(
            snappingSheetController: _controller,
            snapPositions: const [
              SnapPosition(
                  positionPixel: 0.0,
                  snappingCurve: Curves.elasticOut,
                  snappingDuration: Duration(milliseconds: 750)),
              SnapPosition(positionFactor: 0.2),
            ],
            sheetBelow: SnappingSheetContent(
              child: Container(
                color: Colors.white,
                child: Card(
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(
                                (user.url != null) ?
                                  user.url:
                                    user.tempAvatar
                              ), fit: BoxFit.contain),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(10.0)),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text.rich(TextSpan(
                                text: user.user.email,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                            ),
                            TextButton(
                              onPressed: () async {
                                FilePickerResult result =
                                    await FilePicker.platform.pickFiles();
                                if (result != null) {
                                  Reference ref =
                                      user.storage.ref().child("image1" + user.user.email);
                                  UploadTask uploadTask = ref.putFile(
                                      File(result.files.single.path)
                                  );
                                  uploadTask.then((res) {
                                    res.ref.getDownloadURL()
                                        .then((value) => setState(() {
                                              user.url = value.toString();
                                            }));
                                  });
                                }
                              },
                              child: Text(
                                'Change Avatar',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.teal,
                                // onSurface: Colors.white,
                                shadowColor: Colors.grey,
                                elevation: 5,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Placeholder(
              //   color: Colors.blue,
              // ),
              //heightBehavior: SnappingSheetHeight.fit()
            ),
            grabbing: Container(
              color: Colors.grey,
              child: ListTile(
                title: Text(
                  "Welcome Back, " + user.user.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing:
                    Icon(Icons.keyboard_arrow_up_sharp, color: Colors.black54),
                onTap: () => setState(() {
                  (_controller.currentSnapPosition !=
                          _controller.snapPositions.first)
                      ? _controller
                          .snapToPosition(_controller.snapPositions.first)
                      : _controller
                          .snapToPosition(_controller.snapPositions.last);
                }),
              ),
            ),
            sheetAbove: SnappingSheetContent(),
            child: Stack(children: [
              _buildSuggestions(),
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5.0,
                    sigmaY: 5.0,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: (_controller.snapPositions == null) ? 0.0 :
                    (_controller.currentSnapPosition ==
                        _controller.snapPositions.first) ? 0.0 : 2000.0,
                    height: (_controller.snapPositions == null) ? 0.0 :
                    (_controller.currentSnapPosition ==
                        _controller.snapPositions.first) ? 0.0 : 2000.0,
                    color: Colors.grey.withOpacity(0),
                  ),
                ),
              ),
            ]),
    ),
      );
    } else {
      return _buildSuggestions();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _pushSaved,
          ),
          if (user.status == Status.Authenticated)
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  setState(() {
                    _pushLogout();
                  });
                })
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: _pushLogin,
            )
        ],
      ),
      body: homePage(),
    );
  }

  Widget _buildRow(String pair) {
    final alreadySaved = user.saved.contains(pair);
    return ListTile(
      title: Text(
        pair,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved)
            user.deletePair(pair);
          else
            user.addPair(pair);
        });
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index].asPascalCase);
        });
  }
}
