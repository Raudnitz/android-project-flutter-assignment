import 'package:flutter/material.dart';
import 'package:hello_me/user_repository.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

var confirmPass;

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _passwordConfirm = TextEditingController();
  bool validPass = true;
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();

  String get password => _password.toString();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: "");
    _password = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Welcome to Startup Names Generator,\n please log in below',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                    controller: _email,
                    validator: (value) =>
                        (value.isEmpty) ? "Please Enter Email" : null,
                    style: style,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: "Email",
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                    obscureText: true,
                    controller: _password,
                    validator: (value) =>
                        (value.isEmpty) ? "Please Enter Password" : null,
                    style: style,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      labelText: "Password",
                    )),
              ),
              user.status == Status.Authenticating
                  ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      backgroundColor: Colors.redAccent,
                      strokeWidth: 2,
                    ))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.redAccent,
                        child: MaterialButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (!await user.signIn(
                                  _email.text, _password.text))
                                _key.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      "There was an error logging into the app"),
                                ));
                              else {
                                // user.saved = temp;
                                // user.getAvatar();
                                user.pullPairs();
                                Navigator.of(context).pop();
                                //Navigator.of(context).popAndPushNamed('/SnapSheet');
                              }
                            }
                          },
                          child: Text(
                            "Log In",
                            style: style.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0)),
//Sign up
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.teal,
                    child: MaterialButton(
                      onPressed: () {
                        return showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Container(
                                color: Colors.white,
                                padding: MediaQuery.of(context).viewInsets,
                                child: SafeArea(
                                  top: false,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        title: Center(
                                            child: Text(
                                                'Please confirm your password below:')),
                                        // leading: Icon(Icons.edit),
                                        // onTap: () => Navigator.of(context).pop(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: TextFormField(
                                            obscureText: true,
                                            controller: _passwordConfirm,
                                            validator: (value) =>
                                                (value.isEmpty)
                                                    ? "Please Enter Password"
                                                    : null,
                                            style: style,
                                            decoration: InputDecoration(
                                              errorText:
                                                  validPass ? null : "Passwords must match",
                                              prefixIcon:
                                                  Icon(Icons.lock_outline),
                                              labelText: "Password",
                                            )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 10.0),
                                        child: Material(
                                          elevation: 5.0,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          color: Colors.teal,
                                          child: MaterialButton(
                                            onPressed: () async {
                                              validPass =
                                                (_passwordConfirm.text ==
                                                    _password.text);
                                              FocusScope.of(context).unfocus();
                                              if(validPass) {
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  if (!await user.register(
                                                      _email.text,
                                                      _password.text))
                                                    _key.currentState
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "There was an error registering into the app"),
                                                    ));
                                                  else {
                                                    // user.saved = temp;
                                                    user.pullPairs();
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    //Navigator.of(context).popAndPushNamed('/SnapSheet');
                                                  }
                                                }
                                              }
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: style.copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        );
                      },
                      child: Text(
                        "New user? Click here to sign up",
                        style: style.copyWith(
                          color: Colors.white,
                          // fontStyle:
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}

class ModalFit extends StatelessWidget {
  const ModalFit({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Center(child: Text('Please confirm your password below:')),
            // leading: Icon(Icons.edit),
            // onTap: () => Navigator.of(context).pop(),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0, right: 10.0),
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
                obscureText: true,
                // controller: confirmPass,
                validator: (value) => (value.toString() == confirmPass)
                    ? "Passwords must match"
                    : "null",
                // style: style,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  labelText: "Password",
                )),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: TextButton(
                onPressed: null,
                child: Text(
                  'Confirm',
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
              ),
            ),
          )
        ],
      ),
    ));
  }
}
