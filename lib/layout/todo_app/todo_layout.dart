
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../shared/components/components.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

// ignore: must_be_immutable
class HomeLayout extends StatelessWidget
{
  HomeLayout({super.key});

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();


  var titleControler = TextEditingController();
  var bioControler = TextEditingController();
  var timeControler = TextEditingController();
  var dateControler = TextEditingController();




  @override
  Widget build(BuildContext context)
  {
    return BlocProvider(
      create: (BuildContext context ) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit , AppStates>(
        listener: (BuildContext context , AppStates state){
          if(state is AppInsertDatabaseState){
            Navigator.pop(context);
          }
        } ,
        builder: (BuildContext context ,AppStates states )
        {
          AppCubit cubit =AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              backgroundColor: const Color(0xFF43658b),
              title: Text(
                cubit.titles[cubit.currentIndex],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            body: cubit.screen[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () async
              {
                if (cubit.isBottomSheetShow){
                  if(formKey.currentState!.validate()){
                    cubit.insertToDatabase(
                        title: titleControler.text,
                        bio: bioControler.text,
                        time: timeControler.text,
                        date: dateControler.text);

                  }

                }else{

                  scaffoldKey.currentState?.showBottomSheet(
                        (context) => Container(
                      color: Colors.grey[100],
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8,),
                              defaultFormField(
                                controller:titleControler,
                                type: TextInputType.text,
                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                                label:'task title' ,
                                prefix: Icons.title,

                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              defaultFormField(
                                controller:bioControler,
                                type: TextInputType.text,
                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'bio must not be empty';
                                  }
                                  return null;
                                },
                                label:'task bio' ,
                                prefix: Icons.text_fields,

                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              defaultFormField(
                                controller:timeControler,
                                type: TextInputType.datetime,
                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'time must not be empty';
                                  }
                                  return null;
                                },
                                label:'task time' ,
                                onTap: (){
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then((value)
                                  {
                                    timeControler.text = value!.format(context).toString();
                                    // print(value.format(context));
                                  }
                                  );
                                },
                                prefix: Icons.watch_later_outlined,

                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              defaultFormField(
                                controller:dateControler,
                                type: TextInputType.datetime,

                                validate: (String? value){
                                  if(value!.isEmpty){
                                    return 'date must not be empty';
                                  }
                                  return null;
                                },
                                label:'date time' ,
                                onTap: (){
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2030-12-23'),
                                  ).then((value) {
                                    dateControler.text = DateFormat.yMMMd().format(value!);
                                    // print(DateFormat.yMMMd().format(value));
                                  });
                                },
                                prefix: Icons.calendar_today,

                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).closed.then((value) {

                    cubit.changeBottomSheetState(
                      isShow: false,
                      icon: Icons.edit,
                    );
                    showToast(text: 'new task', state: ToastState.NEW);

                  });
                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );

                }
              },
              child: Icon(
                  cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);
              },
              items:
              const [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                icon: Icon(
                  Icons.check_circle_outline,
                ),
                label: 'Done',
              ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive,
                  ),
                  label: 'archive',
                ),
              ],
            ),
          );
        },
      ),
    );
  }




}



