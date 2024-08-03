
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/components/components.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

  class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return
      BlocConsumer<AppCubit , AppStates>(
        listener: (context , state) {},
        builder: (context , state){
         return ConditionalBuilder(
           condition: AppCubit.get(context).newTasks.isNotEmpty,
           builder: (context) =>ListView.separated(
             itemBuilder: (context , index) =>buildTaskItem(AppCubit.get(context).newTasks[index] ,context),
             separatorBuilder: (context , index) => Container(
               width: double.infinity,
               height: 1.0,
               color: Colors.grey[300],
             ),
             itemCount: AppCubit.get(context).newTasks.length,
           ),
           fallback:(context) => noTask(),
         );
        },
      );
  }
}
