import 'dart:io';

import 'package:dio/dio.dart'; //dioパッケージをインストールしてHTTP通信を行えるようにする
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  //取得したデータを格納するためにリスト型の変数imageListを用意しておく　初期値では空のリスト準備しておくので空白
  List imageList = [];

  //アプリを起動した時点で1度だけ全データを取得すればいいからinitStateのタイミングで実行するようにしたい
  Future<void> fetchImage(String text) async {
    //引数にtext(TextFromFieldで取得したtext)を与えることで、fetchImage関数が動くときに同時に検索ができるようにしておく
    Response response = await Dio().get(
      'https://pixabay.com/api/?key=29650737-888bc1c5d45e4f74325569542&q=$text&image_type=photo&pretty=true&per_page=100',
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
    fetchImage('花'); //このinitStateのタイミングでfetchImageを実行することで初回のビルド時にデータを取得するようにできる　初回以降は呼び出されない　//初期値は花としておく
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          decoration: const InputDecoration(
            filled: true, //filledプロパティはtrueにすることで背景色を変更することができる
            fillColor: Colors.white,
          ),
          onFieldSubmitted: (text) {
            //onFieldSubmittedプロパティはTextFormFieldに入力した値を取得することができる　取得した値は変数text(引数に入っているtext)に代入される
            // print(text);
            fetchImage(text); //変数textに代入された値(検索のために入力した値)を元にfetchImage関数が動き画像を検索してくれる。
          },
        ),
      ),
      //以下の処理は前提として引数のindexと変数imageに格納されるimageListのindexが同じことが前提(そもそも同じでないといけない)であり、同じである場合は自動的に該当するセルにデータを表示させてくれることを理解しておかなければいけない
      body: GridView.builder(
        //GridViewウィジェットで取得したデータを格子状に表示することが可能できる
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), //gridDelegateプロパティではGridViewのレイアウトを調整できます。このケースでは3列で表示するように指定しています。
        itemCount: imageList.length, //itemCountプロパティでは変数imageListに格納したhitsのデータの数をカウントしている
        itemBuilder: (context, index) {
          //引数contextはGridViewそれ自体の位置を指しており、引数indexはその中にあるそれぞれのセルに割り振られてた番号
          Map<String, dynamic> image = imageList[index]; //変数imageListに格納されているhitsのデータをindexを使用して番号で変数imageに代入している
          return InkWell(
            //InkWellで囲ったウィジェットをボタンとして選択することができる onTapプロパティの中に処理を記述しておくことでボタンを押した時の動作を指定することができる
            onTap: () async {
              Directory dir = await getTemporaryDirectory(); //Directory型の変数dirにgetTemporaryDirectoryで取得した画像を保存する先のパスを代入している
              Response response = await Dio().get(
                //Response型の変数responseに対してDioでwebformatURLを取得し、responseTypeでバイトデータで受け取るように指定することで編集responseに取得したURLに画像のバイト数を代入している
                image['webformatURL'],
                options: Options(
                  responseType: ResponseType.bytes,
                ),
              );
              File imageFile = await File('${dir.path}/image.png').writeAsBytes(response.data); //取得した画像のバイトデータを一時的に取得したファイルパスのディレクトリにimage.pngと名前をつけて保存をしていて、その保存が完了したファイルパスをImage.pngに代入している
              // ignore: deprecated_member_use
              await Share.shareFiles([imageFile.path]); //share_plusパッケージをインストーしてこの一行を追加することで画像を選択するとシェア画面がポップアップで出てくる　シェアするだけでなく自分のスマホに保存もできる
            },
            child: Stack(
              //Stackを使うことでchildren内に記載したwidgetが順番に上に重なっていく
              fit: StackFit.expand, //Stackの領域を最大限広げる
              children: [
                Image.network(
                  image['previewURL'], //変数imageに格納されたindex番号に該当するデータ内のpreviewURLの画像を表示(return)させてセルに表示している
                  fit: BoxFit.cover, //imageの大きさを各セルの領域いっぱいにまで広げる
                ),
                Align(
                  //Alignの中に配置した要素をの位置を調整することができる
                  alignment: Alignment.bottomRight, //今回のケースでは右下に配置している
                  child: Container(
                    color: Colors.white, //背景色を白で設定
                    child: Row(
                      mainAxisSize: MainAxisSize.min, //Rowの中の要素の大きさを可能な限り小さくしている
                      children: [
                        const Icon(
                          Icons.thumb_up_alt_outlined,
                          size: 14, //mainAxisSizeで大きさを調整してはいるものの、ちょっと大きいのでsizeプロパティで調整
                        ),
                        Text(image['likes'].toString()),
                      ],
                    ), //likesはint型の値なので文字列として表示したい場合はtoStringをつけるか$をつけて文字列変換する
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
