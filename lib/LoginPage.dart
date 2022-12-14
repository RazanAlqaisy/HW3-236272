import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AuthProvider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
//throw UnimplementedError();

}
class _LoginState extends State<Login> {
  TextEditingController? emailController = new TextEditingController();
  TextEditingController? passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Login              ')),
        ),
        body: Center(
            child: SizedBox(
                width: 350,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      const Text(
                          'Welcome to Startup Names Generator, please log in below'),
                      const SizedBox(height: 20),
                      TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                          )),
                      const SizedBox(height: 20),
                      TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                          )),
                      const SizedBox(height: 10),
                      user.status == Status.Authenticating
                          ? Center(child: CircularProgressIndicator())
                          : TextButton(
                          onPressed: () async {
                            if (await user.signIn(
                                emailController!.text, passwordController!.text)) {
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'There was an error logging into the app.')));
                            }
                          },
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              fixedSize: const Size(350, 20),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.deepPurple),
                          child: const Text('Login')),
                      //user.status == Status.Authenticating
                      //? Center(child: CircularProgressIndicator())
                      TextButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      height: 200,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: <Widget>[
                                            const Text(
                                                'Please confirm your password below:'),
                                            const Divider(),
                                            legal(
                                                password: passwordController!.text,
                                                email: emailController!.text,
                                                user: user)
                                          ],
                                        ),
                                      ),
                                    ));
                              },
                            );
                          },
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              fixedSize: const Size(350, 20),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.lightBlue),
                          child: const Text('New user? Click to sign up'))
                    ]))));
  }
}

class legal extends StatefulWidget {
  final String? password;
  final String? email;
  final AuthProvider? user;
  const legal({Key? key, this.password, this.email, this.user})
      : super(key: key);

  @override
  _legalState createState() => _legalState();
}

class _legalState extends State<legal> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              validator: (text) {
                if (widget.password != text) return 'Passwords must match';
                if (widget.password == null || text == null)
                  return 'Passwords must not be empty';
                return null;
              },
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              )),
          const SizedBox(height: 15),
          ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await widget.user?.signUp(widget.email!, widget.password!);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              })
        ],
      ),
    );
  }
}
