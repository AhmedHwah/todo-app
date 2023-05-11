import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/shared/components.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';
import 'package:todoapp/views/archived_tasks.dart';
import 'package:todoapp/views/done_tasks.dart';
import 'package:todoapp/views/tasks_view.dart';

class HomeLayout extends StatelessWidget {
   HomeLayout({Key? key}) : super(key: key);
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.menu),
      label: 'Tasks',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.file_download_done_outlined),
      label: 'Done',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.archive_outlined),
      label: 'Archived',
    ),
  ];



  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController title = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController date = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppCubit>(
      create: (context) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit,AppState>(
        listener: (context, state) {
          if(state is AppInsertDatabaseState)
            Navigator.pop(context);
        },
        builder: (context, state) {
          var cubit = AppCubit.get(context);
         return Form(
            key: formKey,
            child: Scaffold(
              key: scaffoldKey,
              floatingActionButton: FloatingActionButton(
                onPressed: () {

                  if (cubit.isTaskShown) {
                    if (formKey.currentState!.validate()) {
                      cubit.insertIntoDatabase(title: title.text, date: date.text, time: time.text);
                      cubit.changeBottomSheet(false, Icons.edit);
                    }
                  } else {
                    scaffoldKey.currentState!
                        .showBottomSheet(
                          (context) => Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultTextField(
                                controller: title,
                                validate: (String? value) {
                                  if (value!.isEmpty)
                                    return 'Title must not be left Empty';
                                  return null;
                                },
                                type: TextInputType.text,
                                title: 'Title'),
                            SizedBox(
                              height: 25,
                            ),
                            defaultTextField(
                                controller: time,
                                type: TextInputType.datetime,
                                onTap: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value) {
                                    time.text = value!.format(context);
                                  });
                                },
                                validate: (String? value) {
                                  if (value!.isEmpty)
                                    return 'Time must not be left Empty';
                                  return null;
                                },
                                title: 'Time'),
                            SizedBox(
                              height: 25,
                            ),
                            defaultTextField(
                                controller: date,
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2030-04-14'),
                                  ).then((value) {
                                    print(DateFormat.yMMMd().format(value!));
                                    date.text = DateFormat.yMMMd().format(value!);
                                  });
                                },
                                type: TextInputType.datetime,
                                validate: (String? value) {
                                  if (value!.isEmpty)
                                    return 'Date must not be left Empty';
                                  return null;
                                },
                                title: 'Date'),
                          ],
                        ),
                      ),
                    )
                        .closed
                        .then((value) {
                     cubit.changeBottomSheet(false, Icons.edit);
                    });
                    // For the shown bottmsheet
                    cubit.changeBottomSheet(true, Icons.add);
                  }
                },
                child: Icon(cubit.buttonIcon),
              ),
              body: cubit.views[cubit.currentIndex],
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.black),
                elevation: 0,
                backgroundColor: Colors.white,
                title: Text(
                  cubit.titles[cubit.currentIndex],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                onTap: (index) {
                  cubit.changeBottomNavBar(index);
                },
                currentIndex: cubit.currentIndex,
                items: items,
              ),
            ),
          );
        },
      ),
    );
  }

}
