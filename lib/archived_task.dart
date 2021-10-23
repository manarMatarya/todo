import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/cubit/mycubit_cubit.dart';

import 'component/build_task_item.dart';

class ArchivedTask extends StatelessWidget {
  const ArchivedTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MycubitCubit, MycubitState>(
      builder: (BuildContext context, state) {
        var tasks = MycubitCubit.get(context).archivedTasks;

        return tasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.menu, color: Colors.black54, size: 80),
                    Text(
                      'No Tasks yet! , Add tasks ..',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemBuilder: (context, i) {
                  return buildTaskItem(tasks[i], context);
                },
                separatorBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                  );
                },
                itemCount: tasks.length);
      },
      listener: (BuildContext context, Object? state) {},
    );
  }
}
