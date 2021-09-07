import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/cubit/app_cubit.dart';
import 'package:todo/shared/cubit/app_states.dart';

class DoneTasksScreen extends StatelessWidget {
  const DoneTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
        builder: (context, state) {
          var tasks = AppCubit
              .get(context)
              .doneTasks;
          return ConditionalBuilder(
              condition: tasks.length > 0,
              builder: (context) {
                return ListView.separated(
                    itemBuilder: (context, index) {
                      return buildTaskItem(context, tasks[index]);
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        color: Colors.grey[300],
                        width: double.infinity,
                        height: 1,
                      );
                    },
                    itemCount: tasks.length);
              },
              fallback: (context) {
                return Center(
                  child: Text('No Tasks Yet'),
                );
              });
        },
        listener: (context, state) {});
  }
}
