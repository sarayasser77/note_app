import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:noteapp/features/Addnotes/presentation/view/editScreen.dart';
import 'package:noteapp/features/core/utilies/styles.dart';
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  var titleController =TextEditingController();
  var descController =TextEditingController();
bool isClicked=false;

final ref=Hive.box('Notes');

List<Map<String,dynamic>> notes=[];

void addNote({required String title,required String desc})async{

  await
  ref.add({
  'title':title,
  'desc':desc
});
  getNotes();
}

void getNotes(){
 setState(() {
   notes= ref.keys.map((e) {
     final currentNote= ref.get(e);
     return{
       'key':e,
       'title':currentNote['title'],
       'desc':currentNote['desc'],
     };
   }).toList();
 });
 debugPrint("${notes.length}");
}

void deleteNote({required int noteId})async{
 await ref.delete(noteId);
 getNotes();
}


List<Map<String,dynamic>> filterdData=[];
void FilterSearch({required String input}){
 filterdData= notes.where((element) => element['title'].toString().toLowerCase().startsWith(input.toLowerCase())).toList();
}


GlobalKey<ScaffoldState> scaffoldKey=GlobalKey<ScaffoldState>();


@override
  void initState() {
    // TODO: implement initState
  checkConn();
  getNotes();
  super.initState();
  }
void checkConn()async{
   await Connectivity().checkConnectivity();
}

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context,snapShot){
        return Scaffold(
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.purple.shade300,
              child: Icon(Icons.add),
              onPressed: () {
                scaffoldKey.currentState!.showBottomSheet((context){
                  return Container(
                    padding: EdgeInsets.all(20),
                    child:  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                              hintText: 'title',
                              border: UnderlineInputBorder()
                          ),



                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                              hintText: 'describtion',
                              border: UnderlineInputBorder()
                          ),
                        ),
                        MaterialButton(
                          color: Colors.purple,
                          textColor: Colors.white,
                          child: const Text("Add New Note"),
                          onPressed: (){
                            if(titleController.text.isNotEmpty&&descController.text.isNotEmpty){
                              addNote(title: titleController.text, desc: descController.text);
                              Navigator.pop(context);
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill data")));
                            }
                          },
                        )
                      ],
                    ),
                  );
                }).closed.then((value){
                  titleController.clear();
                  descController.clear();
                });
              },

            ),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.purple,
              title: isClicked==false?const Text('Note')
                  : SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (input){
                    setState(() {
                      FilterSearch(input: input);

                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(.4)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,),
                          borderRadius: BorderRadius.circular(10)
                      )
                  ),
                ),
              ),

              actions: [
                GestureDetector(
                    onTap:(){
                      setState(() {
                        isClicked=!isClicked;

                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(isClicked==false?Icons.search:Icons.cancel),
                    ))
              ],
            ),
            body:snapShot.data==ConnectivityResult.none?const Center(
                child:  Text("Check internet Connection",style: Styles.textStyle20,))
                :Padding(
              padding: const EdgeInsets.all(8.0),
              child: notes.isEmpty?
              Center(child: Text("No Notes Till Now",style:Styles.textStyle20.copyWith(color: Colors.purple),))
                  :ListView.separated(
                  itemBuilder: (context,index){
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration:BoxDecoration(color: Colors.grey.withOpacity(.1,),borderRadius: BorderRadius.circular(20)) ,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${filterdData.isEmpty?notes[index]['title']:filterdData[index]['title']}",style: Styles.textStyle20,),
                                  SizedBox(height: 10,),
                                  Text("${filterdData.isEmpty?notes[index]['desc']:filterdData[index]['desc']}"),
                                ],
                              ),
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return EditScreen(noteKey: notes[index]['key'],title: notes[index]['title'],desc: notes[index]['desc'],);
                                        }));
                                      },
                                      child: Icon(Icons.edit)),
                                  const SizedBox(height: 5,),
                                  GestureDetector(
                                      onTap: (){
                                        deleteNote(noteId: notes[index]['key']);
                                      },
                                      child: const Icon(CupertinoIcons.delete,color: Colors.red,))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context,index){
                    return const SizedBox(height: 10,);
                  },
                  itemCount:filterdData.isEmpty? notes.length:filterdData.length),
            )
        );
      },

    );
  }
}
