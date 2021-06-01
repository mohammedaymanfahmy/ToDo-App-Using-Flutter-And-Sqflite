import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cuobit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  Color background = Colors.blue,
  bool isUpperCase = true,
  @required Function function,
  @required String text,
}) =>
    Container(
      width: width,
      color: background,
      child: MaterialButton(
        onPressed: function,
        child: Text(
          isUpperCase ? text.toUpperCase() : text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );

Widget defaultFormField({
  @required TextEditingController controller,
  @required TextInputType type,
  Function onSubmit,
  Function onChang,
  Function onTap,
  bool isClickable = true,
  @required Function validate,
  @required label,
  @required IconData prefix,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: type,
      onFieldSubmitted: onSubmit,
      onChanged: onChang,
      onTap: onTap,
      validator: validate,
      enabled: isClickable,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          prefix,
        ),
        border: OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model,context) => Dismissible(
  key: Key(model['id'].toString()),
  child:   Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text('${model['time']}'),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 15,
            ),
            IconButton(
              icon: Icon(Icons.check_box,
              color:Colors.green,
              ),
              onPressed: () {
                AppCubit.get(context).updateData(status: 'done', id: model['id']);
              },
            ),
            IconButton(
              icon: Icon(Icons.archive,
              color: Colors.black45,),
              onPressed: () {
                AppCubit.get(context).updateData(status: 'archived', id: model['id']);
              },
            ),
          ],
        ),
      ),
  onDismissed:(direction){
    AppCubit.get(context).deleteData(id: model['id'],);
  } ,
);

Widget tasksBuilder({
  @required List<Map>tasks,
})=> ConditionalBuilder(
  condition: tasks.length>0,
  builder: (context)=>ListView.separated(
      itemBuilder: (context,index)=> buildTaskItem(tasks[index],context),
      separatorBuilder: (context,index)=>Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
      itemCount: tasks.length),
  fallback: (context)=>Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size:60,
          color: Colors.grey,
        ),
        Text('Add Some Tasks',
          style: TextStyle(
            color: Colors.grey,
          ),)
      ],
    ),
  ),
);