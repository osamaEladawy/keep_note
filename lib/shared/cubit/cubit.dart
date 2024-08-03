import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../../screens/archived_tasks/archived_task_screen.dart';
import '../../screens/done_tasks/done_task_screen.dart';
import '../../screens/new_tasks/new_task_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<Widget> screen = [
    const NewTaskScreen(),
    const DoneTaskScreen(),
    const ArchivedTaskScreen(),
  ];
  List<String> titles = [
    'new task',
    'done task',
    'archived task',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  late Database database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        if (kDebugMode) {
          print('database create');
        }

        database
            .execute(
                'CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,bio TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          if (kDebugMode) {
            print('create table');
          }
        }).catchError((error) {
          if (kDebugMode) {
            print('error when creating table ${error.toString()}');
          }
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        if (kDebugMode) {
          print('database open');
        }
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String bio,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title,bio,date,time,status)VALUES("$title","$bio","$date","$time","new")')
          .then((value) {
        if (kDebugMode) {
          print('$value inserted successfully');
        }
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
        if (kDebugMode) {
          print('database open');
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('error when inserting new record ${error.toString()}');
        }
      });
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });

      emit(AppGetDatabaseState());
    });
  }

  // ignore: non_constant_identifier_names
  void UpdateData({
    required String status,
    required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    database.rawDelete(
      'DELETE FROM tasks WHERE id = ?',
      [id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  bool isBottomSheetShow = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShow = isShow;
    fabIcon = icon;

    emit(AppChangeBottomSheetState());
  }
}
