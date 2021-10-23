import 'package:flutter/material.dart';
import 'package:todo/shared/cubit/mycubit_cubit.dart';

Widget buildTaskItem(Map map, context) {
  return Dismissible(
    onDismissed: (val) {
      MycubitCubit.get(context).deleteTask(id: map['id']);
    },
    key: Key('${map['id']}'),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 40.0,
            child: Text(
              '${map['status']}',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${map['title']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${map['date']}',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            width: 60,
          ),
          IconButton(
            onPressed: () {
              MycubitCubit.get(context).donePressed(map['id']);
            },
            icon: MycubitCubit.get(context).doneIcon,
          ),
          IconButton(
            onPressed: () {
              MycubitCubit.get(context).archievePressed(map['id']);
            },
            icon: MycubitCubit.get(context).archievIcon,
          ),
        ],
      ),
    ),
  );
}
