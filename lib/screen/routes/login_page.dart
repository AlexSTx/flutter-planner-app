import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import 'package:planner_app/providers/session.dart';
import "package:planner_app/controller/user_controller.dart";
import "package:planner_app/model/user.dart";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 100, 16, 16),
          child: Column(
            children: [
              const Icon(
                Icons.calendar_view_week_outlined,
                size: 64,
              ),
              const SizedBox(height: 32),
              const LoginForm(),
              const SizedBox(height: 64),
              const Text("Ainda não tem conta?"),
              TextButton(
                  onPressed: () => {Navigator.pushNamed(context, '/register')},
                  child: const Text('Registrar')),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;
  late UserController controller;
  bool invalidCredentials = false;

  _LoginFormState() {
    controller = UserController();
  }

  void _submit(Session session) async {
    final form = _formKey.currentState;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (form!.validate()) {
      form.save();

      try {
        User? user = await controller.getLogin(_email!, _password!);

        if (user == null) {
          messenger.showSnackBar(const SnackBar(content: Text("User not found!")));
          return;
        }

        session.logIn(user);
        navigator.pushReplacementNamed('/app');
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(
      builder: (context, session, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) => _email = value,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'O campo de email não pode estar vazio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                onSaved: (value) => _password = value,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'O campo de senha não pode estar vazio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => _submit(session), child: const Text('Fazer Login'))
            ],
          ),
        );
      },
    );
  }
}
