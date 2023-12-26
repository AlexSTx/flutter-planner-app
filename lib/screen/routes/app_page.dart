import "package:flutter/material.dart";
// import "package:planner_app/helper/database_helper.dart";
import 'package:planner_app/screen/subpages/calendar_page.dart';
import 'package:planner_app/screen/subpages/dashboard_page.dart';
import 'package:planner_app/screen/subpages/search_page.dart';
import "package:provider/provider.dart";

import 'package:planner_app/providers/session.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final pagesInfo = [
    {
      "title": const Text("Task Boards"),
      "btnRoute": '/task_board_form',
      "destination": const NavigationDestination(
        icon: Icon(Icons.folder),
        label: 'Dashboard',
      ),
      "page": (session) => Dashboard(session: session)
    },
    {
      "title": const Text("Search"),
      "btnRoute": null,
      "destination": const NavigationDestination(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      "page": (session) => Search(session: session),
    },
    {
      "title": const Text("Calendar"),
      "btnRoute": '/task_form',
      "destination": const NavigationDestination(
        icon: Icon(Icons.calendar_today),
        label: 'Calendar',
      ),
      "page": (session) => CalendarPage(session: session),
    },
  ];

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      return Scaffold(
        appBar: AppBar(
          title: pagesInfo.map<Text>((page) => page["title"] as Text).toList()[currentPageIndex],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 128,
                child: DrawerHeader(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Welcome, ${session.session!.name}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.checklist_rounded),
                title: const Text('Tarefas Concluidas'),
                onTap: () {
                  Navigator.pushNamed(context, '/completed');
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay_circle_filled_outlined),
                title: const Text('Tarefas Próximas'),
                onTap: () {
                  Navigator.pushNamed(context, '/upcoming');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Deslogar'),
                onTap: () {
                  session.logOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.logout),
              //   title: const Text('Reset DB'),
              //   onTap: () async {
              //     session.logOut();
              //     final navigator = Navigator.of(context);
              //     DatabaseHelper connection = DatabaseHelper();
              //     await connection.deleteDB();
              //     navigator.pushReplacementNamed('/login');
              //   },
              // ),
            ],
          ),
        ),
        floatingActionButton: pagesInfo.map<Widget?>((page) {
          return page["btnRoute"] == null
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(page["btnRoute"] as String);
                    // .then((_) => Navigator.popAndPushNamed(context, '/app'));
                  },
                  child: const Icon(Icons.add),
                );
        }).toList()[currentPageIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentPageIndex,
          onDestinationSelected: (value) => setState(() => currentPageIndex = value),
          destinations: pagesInfo
              .map<NavigationDestination>((page) => page["destination"] as NavigationDestination)
              .toList(),
        ),
        body: pagesInfo
            .map<Widget>((page) => (page["page"] as Function)(session))
            .toList()[currentPageIndex],
      );
    });
  }
}
