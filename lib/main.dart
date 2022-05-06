import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _users = _firestore.collection('users');

  Future<void> addUser() async {
    await _users.add({
      'name': 'rey',
      'age': 12,
    });
    print('追加完了');
  }

  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // firestoreのデータ取り込み
      body: FutureBuilder(
        future: _users.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasError){
            return const Text('エラー')
          } else if(snapshot.hasData && snapshot.data!.docs.isEmpty){
            return const Text('ドキュメントなし')
          } else if(snapshot.connectionState == ConnectionState.done){
            List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
            return ListView(
              children: docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String name = data['name'];
                return Text(name);
              },).toList(),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
