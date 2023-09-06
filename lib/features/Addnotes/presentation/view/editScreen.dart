import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noteapp/features/Addnotes/presentation/view/homescreen.dart';

class EditScreen extends StatelessWidget {



  EditScreen({super.key, required this.noteKey,required this.title,required this.desc});


  final String title;
   final String desc;
   final int noteKey;

  final titleController=TextEditingController();
  final descController=TextEditingController();

  final ref=Hive.box('Notes');


  void UpdateNote(){
  ref.put(noteKey, {
    'title':titleController.text,
    'desc':descController.text
  });
}


  @override
  Widget build(BuildContext context) {
    titleController.text=title;
    descController.text=desc;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade300,
        onPressed: (){
          if(titleController.text!=title||descController.text!=desc){
            UpdateNote();
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is No Changes")));
          }
        },
        child: Icon(Icons.save),
      ),
      appBar: AppBar(backgroundColor: Colors.purple,title: Text('Edit'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration:const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Title',
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: descController,
              decoration:const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'description',
              ),
            ),

          ],
        ),
      ),
    );
  }
}
