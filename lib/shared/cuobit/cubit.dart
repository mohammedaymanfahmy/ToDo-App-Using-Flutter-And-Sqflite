import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cuobit/states.dart';
import 'package:flutter/material.dart';

class AppCubit extends Cubit<AppStates> {
  Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY ,'
                ' title TEXT, date TEXT , time TEXT,status TEXT)')
            .then(
          (value) {
            print('Table Created');
          },
        ).catchError((error) {
          print('Error when creating table is : ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDataBase(database);
        print('database Opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert('INSERT INTO tasks(title,date,time,status) VALUES('
              '"$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());
        getDataFromDataBase(database);
      }).catchError((error) {
        print('Error when insert is : ${error.toString()}');
      });
      return null;
    });
  }

  void getDataFromDataBase(database) {
    newTasks=[];
    doneTasks=[];
    archivedTasks=[];
    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element){
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }

  void deleteData({
    @required int id,
  }) async {
     database.rawDelete(
      'DELETE FROM tasks WHERE id = ?', [id],
    ).then((value)
     {
       getDataFromDataBase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  void updateData({
    @required String status,
    @required int id,
  }) async {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getDataFromDataBase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
}
