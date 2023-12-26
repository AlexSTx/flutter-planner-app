import "package:flutter/material.dart";
import "package:planner_app/controller/user_controller.dart";
import "package:planner_app/model/user.dart";

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Criar novo usuário"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 100, 16, 16),
          child: Column(children: [
            const Icon(
              Icons.calendar_view_week_outlined,
              size: 64,
            ),
            const SizedBox(height: 32),
            const RegisterForm(),
            const SizedBox(height: 64),
            const Text("Já possui uma conta?"),
            TextButton(onPressed: () => {Navigator.pop(context)}, child: const Text('Fazer Login')),
          ]),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String? _email, _password, _name;
  late UserController controller;
  bool invalidCredentials = false;

  _RegisterFormState() {
    controller = UserController();
  }

  void _submit() async {
    final form = _formKey.currentState;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (form!.validate()) {
      form.save();

      try {
        bool alreadyRegistered = await controller.userExists(_email!);

        if (alreadyRegistered) {
          messenger.showSnackBar(const SnackBar(content: Text("Esse email já está cadastrado.")));
          return;
        }

        User newUser = User(name: _name!, email: _email!, password: _password!);
        await controller.createUser(newUser);

        messenger.showSnackBar(const SnackBar(content: Text("Usuário cadastrado com sucesso")));

        navigator.pushReplacementNamed('/login');
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            onSaved: (value) => _name = value,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'O campo de nome não pode estar vazio';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
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
          ElevatedButton(onPressed: _submit, child: const Text('Registrar'))
        ],
      ),
    );
  }
}
