import 'package:flutter/material.dart';
import 'package:planner_app/screen/routes/app_page.dart';
import 'package:planner_app/providers/notifiers.dart';
import 'package:planner_app/screen/routes/completed_page.dart';
import 'package:planner_app/screen/routes/register_page.dart';
import 'package:planner_app/screen/routes/board.dart';
import 'package:planner_app/screen/routes/task_board_form.dart';
import 'package:planner_app/screen/routes/task_form.dart';
import 'package:planner_app/screen/routes/upcoming_page.dart';
import 'package:provider/provider.dart';

import 'package:planner_app/screen/routes/login_page.dart';

import 'providers/session.dart';

final routes = {
  "/": (context) => const LoginPage(),
  "/login": (context) => const LoginPage(),
  "/register": (context) => const RegisterPage(),
  "/app": (context) => const AppPage(),
  "/task_board_form": (context) => const TaskBoardForm(),
  "/task_form": (context) => const TaskForm(),
  "/board": (context) => const Board(),
  "/upcoming": (context) => const UpcomingTasks(),
  "/completed": (context) => const CompletedTasks(),
};
void main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => Session()),
      ChangeNotifierProvider(create: (context) => BoardNotifier()),
      ChangeNotifierProvider(create: (context) => TaskNotifier()),
    ],
    child: MaterialApp(
      title: 'Planner App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 25, 43, 80)),
        useMaterial3: true,
      ),
      routes: routes,
      initialRoute: "/",
    ),
  ));
}
