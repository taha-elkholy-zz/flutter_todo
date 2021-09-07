import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/artchived_tasks/archived_tasks_screen.dart';
import 'package:todo/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo/shared/cubit/app_states.dart';

class AppCubit extends Cubit<AppStates> {
  // Constructor match super with initial state of the app
  AppCubit() : super(AppInitialState());

  // create a static object from the AppCubit
  // to be easy to use in many classes
  static AppCubit get(context) => BlocProvider.of(context);

  // titles list
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  // body of scaffold changes between these screens
  // depends on current index
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  // index of current screen
  // starts from 0 in initial state
  int currentIndex = 0;

  void changeCurrentIndex({required int index}) {
    currentIndex = index;
    emit(AppChangeBottomNaveBarState());
  }

  // for toggle between icons of fab button
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  // change state of bottomSheet
  void changeBottomSheetState(
      {required bool isBottomSheetShown, required IconData fabIcon}) {
    this.isBottomSheetShown = isBottomSheetShown;
    this.fabIcon = fabIcon;
    emit(AppChangeBottomSheetState());
  }

  // time value will be shown by this variable
  String time = 'Set Time';

  void setTime({required context, required timeOfDay}) {
    time = timeOfDay.format(context).toString();
    emit(AppChangeTimeState());
  }

  // date value will be shown by this variable
  String date = 'Set Date';

  void setDate({required DateTime? value}) {
    date = DateFormat.yMMMd().format(value!);

    emit(AppChangeDateState());
  }

  // database variable
  late Database database;

  Future<void> createDatabase() async {
    // if database exist it will be opened else it created
    openDatabase('my_app_todo.db', version: 1,
        onCreate: (database, version) async {
      await database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        print('Database created successfully');
      }).catchError((error) {
        print('Error while create database $error');
      });
    }, onOpen: (database) {
      print('database opened');
      // get data from database
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertIntoDatabase({
    required String title,
    required String time,
    required String date,
  }) {
    database.transaction((txn) async {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value inserted into database');
        emit(AppInsertIntoDatabaseState());

        // get data again to refresh
        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error while insert into database $error');
      });
    });
  }

  // list of new tasks
  List<Map> newTasks = [];

  // list of new tasks
  List<Map> doneTasks = [];

  // list of new tasks
  List<Map> archivedTasks = [];

  void getDataFromDatabase(Database database) {
    // loading until the data be ready
    emit(AppGetDatabaseLoadingState());
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

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
    }).catchError((error) {
      print('Error when get data $error');
    });
  }

  void updateData({required String status, required int id}) {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', '$id'],
    ).then((value) {
      emit(AppUpdateDatabaseState());

      // get data again to refresh
      getDataFromDatabase(database);
    });
  }

  void deleteData({required int id}) {
    database.rawUpdate(
      'DELETE FROM tasks WHERE id = ?',
      [id],
    ).then((value) {
      emit(AppDeleteDatabaseState());

      // get data again to refresh
      getDataFromDatabase(database);
    });
  }
}
