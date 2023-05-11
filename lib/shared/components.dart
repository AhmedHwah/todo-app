import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/shared/cubit/cubit.dart';
import 'package:todoapp/shared/cubit/states.dart';
Widget defaultTextField({
  void Function()? onTap,
  String? Function(String? value)? validate,
  required String title,
  TextInputType? type,
  TextEditingController? controller,
}){
  return TextFormField(
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      label: Text(title),

    ),
    controller: controller,
    keyboardType: type,
    onTap: onTap,
    validator: validate,

  );
}
Widget buildTaskItem(task,AppCubit cubit){
 return Dismissible(

   key:Key(task['ID'].toString()),
   child: Padding(
   padding: const EdgeInsets.symmetric(horizontal: 8.0),
     child: Row(
        children: [
          CircleAvatar(
            radius: 45.0,
            child: Text('${task['time']}'),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${task['title']}',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  '${task['date']}',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(width: 20,),
          IconButton(onPressed: (){
            cubit.updateData(task['ID'], 'done');
          }, icon: Icon(Icons.check_box,color: Colors.green,),),
          IconButton(onPressed: (){
            cubit.updateData(task['ID'], 'archive');
          }, icon: Icon(Icons.archive,color: Colors.grey,),),
        ],
      ),
   ),
   onDismissed: (direction){
    print(task);
     cubit.deleteFromDatabase(task['ID']);
   },
 );
}

Widget tasksView({
  required List<Map> tasks,
  required state
}){
  return ConditionalBuilder(
    condition: tasks.length > 0,
    builder: (context) =>ConditionalBuilder(
      condition: state! is! AppLoadingState,
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) =>
              buildTaskItem(tasks[index], AppCubit.get(context)),
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 1,
              color: Colors.grey,
            ),
          ),
          itemCount: tasks.length),
      fallback: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    ),
    fallback: (context) => Center(
      child: Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children: [
          Icon(Icons.menu,color: Colors.grey,size: 120.0,),
          Text('You have no tasks yet, add new tasks',style: TextStyle(
              color: Colors.grey,
              fontSize: 20.0,
              fontWeight: FontWeight.bold
          ),)
        ],
      ),
    ),
  );
}