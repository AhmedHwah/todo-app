import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/shared/cubit/states.dart';
import 'package:todoapp/views/archived_tasks.dart';
import 'package:todoapp/views/done_tasks.dart';
import 'package:todoapp/views/tasks_view.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitialState());
  static AppCubit get(context) => BlocProvider.of<AppCubit>(context);
  int currentIndex = 0;
  late Database database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  List<Widget> views = [
    TasksView(),
    DoneTasks(),
    ArchivedTasks(),
  ];
  List<String> titles = [
    'Current Tasks',
    'Done Tasks',
    'Archivec Tasks',
  ];

  void changeBottomNavBar(index){
    currentIndex = index;
    emit(AppChangeBottomNavState());
  }

  void createDataBase() async {
    await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('Database created');
        database
            .execute(
            'create table tasks (ID integer primary key,title text,date text, time text, status text)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error while createing table : $error');
        });
      },
      onOpen: (db) async {
        print('Database opened');
        readFromDatabase(db);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    }).catchError((error) {
      print('Error while creating database');
    });
  }

  Future insertIntoDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    return await database.transaction((txn) async {
      await txn.rawInsert(
          'insert into tasks(title,date,time,status) values ("$title","$date","$time","new")').then((value) {
            emit(AppInsertDatabaseState());
            readFromDatabase(database);

      });
    });
  }

  Future readFromDatabase(db) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppLoadingState());
    await db.rawQuery('select * from tasks').then((List<Map> value) {
      value.forEach((element) {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDatabaseState());
    });
  }
  bool isTaskShown = false;
  IconData buttonIcon = Icons.edit;
  void changeBottomSheet(isShown,icon){
    isTaskShown = isShown;
    buttonIcon = icon;
    emit(AppChangeBottomState());
  }
  void updateData(int id,String status){
    database.rawUpdate('update tasks set status = ? where id = ?',['$status',id]).then((value) {
      readFromDatabase(database);
      emit(AppUdatetDatabaseState());
    });
  }
  void deleteFromDatabase(int id){
    database.rawDelete('delete from tasks where ID = ?',[id]);
    readFromDatabase(database);
    emit(AppDeleteDatabaseState());
  }
  @override
  void onChange(Change<AppState> change) {
    // TODO: implement onChange
    super.onChange(change);
    print(change);
  }
}