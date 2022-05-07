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
      // 最初に表示される画面
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
  // 変数の定義 リアルタイム追加を実施する.
  // final Stream<QuerySnapshot> _userStream = _users.snapshots();
  //whereメソッドの利用 クエリ的 データの指定
  // final Stream<QuerySnapshot> _userStream = _users.where('name',isEqualTo : 'rey').snapshots();
  // final Stream<QuerySnapshot> _userStream = _users.where('age',isLessThan : 20).snapshots();
  //limitメソッドの利用 クエリ的 何個取ってくるのかという数についての指定
  // final Stream<QuerySnapshot> _userStream = _users.limit(3).snapshots();
  //order byメソッドの利用 クエリ的 並び替えを行う
  // final Stream<QuerySnapshot> _userStream = _users.orderBy('name').snapshots();
  final Stream<QuerySnapshot> _userStream =
      _users.orderBy('name', descending: true).snapshots();

  //userの追加
  Future<void> addUser() async {
    await _users.add({
      'name': 'rey',
      'age': 12,
    });
    print('追加完了');
  }

  // 情報更新の手法　firebaseのデータを変更する感じ
  //ドキュメントのidが必要
  //動的変換は doc.idの取得によって実行
  // "."で繋いでデータの中のtableを変更可能
  Future<void> updateUser(String docId) async {
    //時間がかかる処理にawaitをつける
    await _users.doc(docId).update({
      'name': 'tom',
      'age': 35,
      'addres': {
        'zip_code': 1234567,
        'prefecture': '大阪',
      },
      'address.prefecture': '沖縄',
    });
    print('変更完了');
  }

  //削除メソッド
  // idを取得して削除
  Future<void> deleteUser(String docId) async {
    _users.doc(docId).delete;
    print('削除完了');
  }

  // フィールドの削除 使うことはそこまでない
  // idを受け取ってupdateするfield value deleteをする
  Future<void> deleteField(docId) async {
    _users.doc(docId).update({'age': FieldValue.delete()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // firestoreのデータ取り込み
      // body: FutureBuilder(
      // future: _users.get(),
      // streamではない場合の処理
      // } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {

      // streamにする
      body: StreamBuilder(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('エラー');

            //   return const Text('ドキュメントなし');
            // } else if (snapshot.connectionState == ConnectionState.done) {
            //   List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
            //   return ListView(
            //     children: docs.map(
            //       (doc) {
            //         Map<String, dynamic> data =
            //             doc.data() as Map<String, dynamic>;
            //         String name = data['name'];
            //         return Text(name);
            //       },
            //     ).toList(),
            //   );
            // } else {
            //   //何もわからない時はこれで待つ時間にする。
            //   return const CircularProgressIndicator();
            // }

            //待っている最中を ぐるぐるに、終わったら表示するという形式にする。
            // firebaseのリアルタイムチェンジ streamが一番有名
          } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return const Text('ドキュメントなし');
            //何もわからない時はこれで待つ時間にする。
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            //何もわからない時はこれで待つ時間にする。
            List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
            return ListView(
              children: docs.map(
                (doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  String name = data['name'];
                  //年齢の表示
                  // int age = data['age'];
                  // ?にしないとdelete fieldしたときに困る
                  int? age = data['age'];
                  //リストにして表示する
                  return ListTile(
                    title: Text(name),
                    subtitle: Text(age.toString()),
                    //リストをクリックしたときに更新する idを取得
                    // onTap: () {
                    //   updateUser(doc.id);
                    // },

                    // 削除　データの削除
                    // onTap: () {
                    //   deleteUser(doc.id);
                    // },

                    // フィールドの削除
                    onTap: () {
                      deleteField(doc.id);
                    },
                  );
                },
              ).toList(),
            );
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
