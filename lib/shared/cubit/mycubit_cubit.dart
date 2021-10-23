import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import '../../archived_task.dart';
import '../../done_task.dart';
import '../../new_task.dart';

part 'mycubit_state.dart';

class MycubitCubit extends Cubit<MycubitState> {
  MycubitCubit() : super(MycubitInitial());
  static MycubitCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  late var database;
  static const String dbname = 'todo.db';
  List newTasks = [];
  List doneTasks = [];
  List archivedTasks = [];

//////////////////////////////////////////////////////////////////////////
  IconData fabIcon = Icons.edit;
  bool isSheetShown = false;
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  List<Widget> screens = [
    const NewTask(),
    const DoneTask(),
    const ArchivedTask()
  ];
  List<String> titles = ['New Task', 'Done Task', 'Archived Task'];

  void changeCurrentIndex(index) {
    currentIndex = index;
    emit(BottomNavigationState());
  }

  void createDatabase() {
    database = openDatabase(dbname, version: 1, onCreate: (database, version) {
      database
          .execute(
              'CREATE Table tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) => print('createed table'));
    }, onOpen: (database) {
      getData(database);

      print('open database');
    }).then((value) {
      database = value;
      emit(CreateDatadaseState());
    });
  }

  Future insertTask(title, date, time) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks (title,date,time,status) VALUES ("$title","$date","$time","new")')
          .then((value) {
        emit(InsertToDatabaseState());
        getData(database);
        print('inserted done');
      }).catchError((error) {
        print('error insert');
      });
      //  return Future(() => null);
    });
  }

  void updateTask({required String status, required int id}) {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      emit(UpdateDatabaseState());
      getData(database);
    });
  }

  void deleteTask({required int id}) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      emit(DeleteDatabaseState());
      getData(database);
    });
  }

  void getData(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'done') {
          doneTasks.add(element);
        } else if (element['status'] == 'archived') {
          archivedTasks.add(element);
        } else {
          newTasks.add(element);
        }
      });
      emit(GetDataFromDatabaseState());
    });
  }

  void FABPressed(context) {
    if (isSheetShown) {
      if (formState.currentState!.validate()) {
        insertTask(
                titleController.text, dateController.text, timeController.text)
            .then((value) {
          fabIcon = Icons.edit;

          Navigator.pop(context);
          isSheetShown = false;
        }).catchError((error) {
          print('errorInsert');
        });
      }
    } else {
      scaffoldKey.currentState!
          .showBottomSheet(
            (context) {
              return Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formState,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'title can not be empty';
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            prefixIcon: Icon(Icons.title),
                            label: Text('Title'),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          onTap: () {
                            showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2030-01-01'))
                                .then((value) => dateController.text =
                                    DateFormat.yMMMd().format(value!));
                          },
                          keyboardType: TextInputType.datetime,
                          controller: dateController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'date can not be empty';
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            prefixIcon: Icon(Icons.calendar_today),
                            label: Text('Date'),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          onTap: () {
                            showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now())
                                .then((value) => timeController.text =
                                    value!.format(context));
                          },
                          controller: timeController,
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'time can not be empty';
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            prefixIcon: Icon(Icons.watch_later_outlined),
                            label: Text('Time'),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            elevation: 20,
          )
          .closed
          .then((value) {
            fabIcon = Icons.edit;
            isSheetShown = false;
          });
      fabIcon = Icons.add;
      isSheetShown = true;
    }
    emit(FAPPressedState());
  }

  bool isDoneShecked = false;
  Icon doneIcon = const Icon(Icons.check_box_outline_blank);
  void donePressed(id) {
    if (isDoneShecked) {
      updateTask(status: 'new', id: id);
      doneIcon = const Icon(
        Icons.check_box_outline_blank,
      );
      isDoneShecked = false;
    } else {
      updateTask(status: 'done', id: id);
      doneIcon = const Icon(
        Icons.check_box,
        color: Colors.green,
      );
      isDoneShecked = true;
    }
  }

  bool isArchievShecked = false;
  Icon archievIcon = const Icon(
    Icons.archive,
    color: Colors.black54,
  );
  void archievePressed(id) {
    if (isArchievShecked) {
      updateTask(status: 'new', id: id);
      archievIcon = const Icon(
        Icons.archive_outlined,
        color: Colors.black54,
      );
      isArchievShecked = false;
    } else {
      updateTask(status: 'archived', id: id);
      archievIcon = const Icon(
        Icons.archive,
        color: Colors.black54,
      );
      isArchievShecked = true;
    }
  }
}
