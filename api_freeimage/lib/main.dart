import 'package:dio/dio.dart'; //dioパッケージをインストールしてHTTP通信を行えるようにする
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PixabayPage(),
    );
  }
}

//StatefulWidgetにはinitStateがそもそも内包されている　正確には内包されているStateクラスにオリジナルのinitStateが含まれている。
class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  //関数の記述及び変数の定義はここに記載する

  //取得したデータを格納するためにリスト型の変数imageListを用意しておく　初期値では空のリスト準備しておくの空白
  List imageList = [];

  //アプリを起動した時点で1度だけ全データを取得すればいいからinitStateのタイミングで実行するようにしたい
  Future<void> fetchImage() async {
    Response response = await Dio().get(
      'https://pixabay.com/api/?key=29650737-888bc1c5d45e4f74325569542&q=yellow+flowers&image_type=photo&pretty=true',
    );
    imageList = response.data['hits']; //変数imageListに上記URLから取得したhitsのデータを格納している
    setState(() {}); //画面更新
    // print(response.data['hits']);
  }

  //この関数の処理は初回のビルド時に一度だけ呼び出される overrideされていることによりinitStateの属する_PixabayPageStateクラスの内容がPixabayPageクラスに上書きされることでbuild(アプリの再描画)される仕組みとなっている
  //superは親クラスのメソッドを呼び出す際に使うキーワードでこのケースではStatefulWidgetが継承しているStateクラスのオリジナルのinitStateを呼び出している。
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchImage(); //このinitStateのタイミングでfetchImageを実行することで初回のビルド時にデータを取得するようにできる
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        //GridViewウィジェットで取得したデータを格子状に表示することが可能できる
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), //gridDelegateプロパティではGridViewのレイアウトを調整できます。このケースでは3列で表示するように指定しています。
        itemCount: imageList.length, //itemCountプロパティでは変数imageListに格納したhitsのデータの数をカウントしている
        itemBuilder: (context, index) {
          //contextはGridViewそれ自体の位置を指しており、indexはその中にあるそれぞれのセルに割り振られて番号
          Map<String, dynamic> image = imageList[index]; //変数imageListに格納されているhitsのデータをindexを使用して番号で変数imageに代入している
          return Image.network(image['previewURL']); //変数imageに格納されたindex番号に該当するデータ内のpreviewURLの画像を表示(return)させる
          //これらの処理は前提として引数のindexと変数imageに格納されるimageListのindexが同じことが前提(そもそも同じでないといけない)であり、同じである場合は自動的に該当するセルにデータを表示させてくれることを理解しておかなければいけない
        },
      ),
    );
  }
}
