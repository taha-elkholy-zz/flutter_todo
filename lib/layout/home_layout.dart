import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/cubit/app_cubit.dart';
import 'package:todo/shared/cubit/app_states.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  // scaffold need a key
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // form need a key
  final formKey = GlobalKey<FormState>();

  // controller for the title edit text field
  final titleController = TextEditingController();

  // controller for the time edit text field
  final timeController = TextEditingController();

  // controller for the date edit text field
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //AppCubit cubit = AppCubit.get(context);
    return BlocProvider(
      // AppCubit()..createDatabase() for create database first thing
      create: (context) =>
      AppCubit()
        ..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertIntoDatabaseState) {
            Navigator.pop(context);
          }
          if (state is AppChangeBottomSheetState) {
            titleController.text = '';
            timeController.text = '';
            dateController.text = '';
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.fabIcon),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertIntoDatabase(
                        title: titleController.text,
                        time: cubit.time,
                        date: cubit.date);
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) {
                      return Container(
                        width: double.infinity,
                        child: Form(
                          key: formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Add New Task',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                defaultTextFormField(
                                    controller: titleController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Title is required';
                                      }
                                    },
                                    inputType: TextInputType.text,
                                    label: 'Task Title',
                                    prefix: Icons.text_fields),
                                //defaultTextFormField
                                SizedBox(
                                  height: 20,
                                ),
                                defaultTextFormField(
                                    controller: timeController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Time is required';
                                      }
                                    },
                                    inputType: TextInputType.datetime,
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined,
                                    onTap: () {
                                      showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now())
                                          .then((value) {
                                        cubit.setTime(
                                            context: context,
                                            timeOfDay: value);
                                        timeController.text = cubit.time;
                                      });
                                    }),
                                //defaultTextFormField
                                SizedBox(
                                  height: 20,
                                ),
                                defaultTextFormField(
                                    controller: dateController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Date is required';
                                      }
                                    },
                                    inputType: TextInputType.datetime,
                                    label: 'Task Date',
                                    prefix: Icons.calendar_today_outlined,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(Duration(days: 365)),
                                      ).then((value) {
                                        cubit.setDate(value: value);
                                        dateController.text = cubit.date;
                                      });
                                    }),
                                //defaultTextFormField
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    elevation: 25,
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ) // BottomSheet
                      .closed
                      .then((value) {
                    // when close the bottom sheet
                    // change the state of bottom sheet from open to closed
                    cubit.changeBottomSheetState(
                        isBottomSheetShown: false, fabIcon: Icons.edit);
                  });

                  // change the state of bottom sheet from closed to open
                  cubit.changeBottomSheetState(
                      isBottomSheetShown: true, fabIcon: Icons.add);
                }
              },
            ),
            body: ConditionalBuilder(
                condition: state is AppGetDatabaseLoadingState,
                builder: (context) =>
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                fallback: (context) => cubit.screens[cubit.currentIndex]),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeCurrentIndex(index: index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: 'Archive',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
