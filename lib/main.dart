import 'dart:math';
import 'dart:typed_data';

import 'package:alphabet_search_view/alphabet_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contactlist_demo/ContactUtils.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

void main() async {
  runApp(const MyApp());
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
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact>? contacts;

  final random = Random();

  final formatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    getContact();
  }

  void getContact() async {
    if (await FlutterContacts.requestPermission()) {
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: true);

      print("total contact ${contacts?.length}");

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Share TraitZ",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back_ios_new)),
      ),
      body: (contacts) == null
          ? Center(
              child: CircularProgressIndicator(
              strokeWidth: 10.0,
            ))
          : SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PhysicalModel(
                      color: Colors.black,
                      elevation: 30.0,
                      child: Container(
                          padding: EdgeInsets.all(10.0),
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: [
                              Icon(
                                Icons.ios_share,
                                color: Colors.white,
                              ),
                              TextButton(
                                onPressed: () {
                                  Share.share(ContactUtils.getSharableText(),
                                      subject: ContactUtils.screenTitle);
                                },
                                child: Text("Tap to Share via Social Apps",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    )),
                              ),
                            ],
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PhysicalModel(
                      color: Colors.grey,
                      elevation: 30.0,
                      child: Container(
                          padding: EdgeInsets.all(10.0),
                          width: double.infinity,
                          height: 60,
                          child: Row(
                            children: [
                              Icon(
                                Icons.sms,
                                color: Colors.white,
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                    "Pick a number to share ${ContactUtils.appName}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    )),
                              ),
                            ],
                          )),
                    ),
                  ),
                  Expanded(
                    child: AlphabetSearchView<Contact>.list(
                      decoration: AlphabetSearchDecoration.fromContext(
                        context,
                        titleStyle:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      list: contacts!
                          .map(
                            (e) => AlphabetSearchModel<Contact>(
                              title: (e.name.first.isNotEmpty
                                      ? e.name.first
                                      : "-") +
                                  " " +
                                  (e.name.last.isNotEmpty ? e.name.last : "-"),
                              subtitle: e.phones.isNotEmpty
                                  ? (e.phones.first.number)
                                  : "-",
                              data: e,
                            ),
                          )
                          .toList(),
                      onItemTap: (_, __, item) {
                        if (item.data.phones.isNotEmpty) {
                          List<String> numberList = [
                            item.data.phones.first.number
                          ];

                          sending_SMS(
                              ContactUtils.getSharableText(), numberList);
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Phone number isn't available."),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      buildItem: (_, index, item) {
                        Uint8List? image = contacts![index].photo;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: (contacts![index].photo == null)
                                    ? const CircleAvatar(
                                        child: Icon(Icons.person))
                                    : CircleAvatar(
                                        backgroundImage: MemoryImage(image!)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        item.subtitle!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void sending_SMS(String msg, List<String> list_receipents) async {
    String send_result =
        await sendSMS(message: msg, recipients: list_receipents)
            .catchError((err) {
      print(err);
    });
    print(send_result);
  }
}
