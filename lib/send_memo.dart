
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:dart_web_scraper/common/enums.dart';
import 'package:dart_web_scraper/common/models/parser_model.dart';
import 'package:dart_web_scraper/common/models/parser_options/string_between_parser_options.dart';
import 'package:dart_web_scraper/common/models/parser_options_model.dart';
import 'package:dart_web_scraper/common/models/scraper_config_model.dart';
import 'package:dart_web_scraper/dart_web_scraper/web_scraper.dart';
import 'package:keloke/memo_model_creator.dart';
import 'package:keloke/memo_model_post.dart';

import 'electrum_websocket_service.dart';
import 'memo_code.dart';
import 'memo_transaction_builder.dart';


const mainnetServers = [
"cashnode.bch.ninja", // Kallisti / Selene Official
"fulcrum.jettscythe.xyz", // Jett
"bch.imaginary.cash", // im_uname
"bitcoincash.network", // Dagur
"electroncash.dk", // Georg
"blackie.c3-soft.com", // Calin
"bch.loping.net",
"bch.soul-dev.com",
"bitcoincash.stackwallet.com", // Rehrar / Stack Wallet official
"node.minisatoshi.cash", // minisatoshi
];

void main() async {
  WebScraper webScraper = WebScraper();

  // Map<String, Object> topics = await webScraper.scrape(
  //   url: Uri.parse("https://memo.cash/topics/all"),
  //   scraperConfig: ScraperConfig(
  //     parsers: [
  //       Parser(
  //         id: "topics",
  //         parents: ["_root"],
  //         type: ParserType.element,
  //         selectors: [
  //           "td",
  //         ],
  //         multiple: true
  //       ),
  //       Parser(
  //           id: "topic",
  //           parents: ["topics"],
  //           type: ParserType.text,
  //           selectors: [
  //             "a",
  //           ]
  //       ),
  //       Parser(
  //           id: "topicURL",
  //           parents: ["topics"],
  //           type: ParserType.url,
  //           selectors: [
  //             "a",
  //           ]
  //       ),
  //       Parser(
  //           id: "tbody",
  //           parents: ["_root"],
  //           type: ParserType.text,
  //           selectors: [
  //             "tbody",
  //           ]
  //       )
  //     ],
  //   ),
  // );
  //
  // List<MemoModelTopic> topicList = [];
  //
  // var tbody = topics.values.elementAt(1).toString()
  //     .replaceAll(",", "")
  //     .split("\n");
  // List<String> cleanBody = [];
  //
  // for (String line in tbody.clone()) {
  //   if (line.trim().isNotEmpty)
  //     cleanBody.add(line.trim());
  // }
  //
  // int itemIndex = 0;
  // for (Map<String, Object> value in topics.values.first as Iterable ) {
  //   topicList.add(new MemoModelTopic(
  //       header: value["topic"].toString(),
  //       url: value["topicURL"].toString(),
  //       followerCount: int.parse(cleanBody[itemIndex+3]),
  //       lastPost: cleanBody[itemIndex+1],
  //       postCount: int.parse(cleanBody[itemIndex+2])));
  //   itemIndex += 4;
  // }
  //
  // for (MemoModelTopic m in topicList) {
  //   print(m.header);
  //   print(m.url);
  //   print(m.followerCount);
  //   print(m.postCount);
  //   print(m.lastPost);
  // }

  Map<String, Object> posts = await webScraper.scrape(
    url: Uri.parse("https://memo.cash/topic/Bitcoin+Map"),
    scraperConfig: ScraperConfig(
      parsers: [
        Parser(
            id: "posts",
            parents: ["_root"],
            type: ParserType.element,
            selectors: [
              ".topic-post",
            ],
            multiple: true
        ),
        Parser(
            id: "msg",
            parents: ["posts"],
            type: ParserType.text,
            selectors: [
              ".message",
            ]
        ),
        // Parser(
        //     multiple: true,
        //     id: "profilePic",
        //     parents: ["posts"],
        //     type: ParserType.url,
        //     selectors: [
        //       ".profile-pic",
        //     ]
        //
        // ),
        // Parser(
        //     multiple: true,
        //     id: "txhash",
        //     parents: ["_root"],
        //     type: ParserType.attribute,
        //     selectors: [
        //       "topic-post::data-tx-hash",
        //     ]
        //
        // ),
        Parser(
            id: "profileUrl",
            parents: ["posts"],
            type: ParserType.url,
            selectors: [
              ".profile",
            ]

        ),
        Parser(
            id: "txhash",
            parents: ["posts"],
            type: ParserType.element,
            selectors: [
              "input",
            ]


        ),
        // Parser(
        //     multiple: true,
        //     id: "urls",
        //     parents: ["posts"],
        //     type: ParserType.url,
        //     selectors: [
        //       ".message",
        //     ]
        //
        // ),
        Parser(
            id: "images",
            parents: ["posts"],
            type: ParserType.url,
            selectors: [
              ".imgur",
            ]
        ),
              Parser(
                multiple: true,
                  id: "posttext",
                  parents: ["_root"],
                  type: ParserType.text,
                  selectors: [
                    ".topic-post",
                  ]
              ),
        // Parser(
        //     multiple: true,
        //     id: "posturls",
        //     parents: ["_root"],
        //     type: ParserType.url,
        //     selectors: [
        //       ".topic-post",
        //     ]
        // ),
        // Parser(
        //     multiple: true,
        //     id: "posturlParams",
        //     parents: ["_root"],
        //     type: ParserType.element,
        //     selectors: [
        //       ".topic-post",
        //     ]
        // ),
        // Parser(
        //     id: "created",
        //     parents: ["posts"],
        //     type: ParserType.attribute,
        //     selectors: [
        //       "title",
        //     ]
        // ),
        // Parser(
        //     id: "allposts",
        //     parents: ["_root"],
        //     type: ParserType.strBetween,
        //     selectors: ,
        //     parserOptions: ParserOptions.stringBetween(
        //         options: StringBetweenParserOptions(
        //             start: '<div id="all-posts" style="position:relative;">',
        //             end: '<form id="form-new-topic-message"')),
        // )
      ],
    ),
  );

  List<MemoModelPost> postList = [];

  var allPosts = posts.values.elementAt(1).toString()
      .replaceAll(",", "")
      .split("\n");
  List<String> cleanPosts = [];
  List<String> txHashList = [];

  for (String line in allPosts.clone()) {
    if (line.trim().isEmpty)
      continue;

    String trimmedLine = line.trim();
    cleanPosts.add(trimmedLine);

    var pattern = 'MemoApp.Form.LikesToggle("';
    if (trimmedLine.startsWith(pattern))
      txHashList.add(trimmedLine.substring(pattern.length
          , pattern.length + "3108a3898df75d4f2c972f0543cb9b6ed6cf6c8d84f01a60627bb3455b084bce".length));
  }

  int index = 0;
  for (Map<String, Object> value in posts.values.first as Iterable ) {
    postList.add(new MemoModelPost(
        text: value["msg"].toString(),
        txHash: txHashList[index],
        creator: MemoModelCreator(name: cleanPosts[1],
            id: value["profileUrl"].toString().substring(8))));
        // txHash: int.parse(cleanBody[itemIndex+3]),
        // lastPost: cleanBody[itemIndex+1],
        // postCount: int.parse(cleanBody[itemIndex+2])));
    index ++;
  }

  for (MemoModelPost p in postList) {
    print(p.text);
    print(p.creator!.name);
    print(p.creator!.id);
    print(p.txHash);
  }


  // await print("\n\n" + doMemoAction("ProfilePostMessage", MemoCode.ProfilePostMessage));
  // print("\n${await doMemoAction("IMG1 https://imgur.com/eIEjcUe", MemoCode.ProfilePostMessage,"")}");
  // print("\n${await doMemoAction("IMG2 https://i.imgur.com/eIEjcUe.jpeg", MemoCode.ProfilePostMessage,"")}");
  // print("\n${await doMemoAction("YT1 https://youtu.be/dQw4w9WgXcQ", MemoCode.ProfilePostMessage,"")}");
  // print("\n${await doMemoAction("OD1 https://odysee.com/@BitcoinMap:9/HijackingBitcoin:73", MemoCode.ProfilePostMessage,"")}");
  // print("\n${await doMemoAction("OD2 https://odysee.com/%24/embed/%40BitcoinMap%3A9%2FHijackingBitcoin%3A73?r=9n3v5rTk1CsSYkoqD3gER4SHNML8SxwH", MemoCode.ProfilePostMessage,"")}");

  // print("\n${await doMemoAction("YT2 https://www.youtube.com/watch?v=dQw4w9WgXcQ", MemoCode.ProfilePostMessage,"")}");
  // var other = await doMemoAction("https://imgur.com/eIEjcUe.jpg", MemoCode.SetProfileImgUrl, "");
  // print("\n" + other);
  // other = await doMemoAction("Keloke", MemoCode.SetProfileName);
  // print("\n" + other);
  // other = await doMemoAction("Ke paso en Barrio Bitcoin", MemoCode.SetProfileText);
  // print("\n" + other);
  // other = await doMemoAction("Bitcoin+Map", MemoCode.TopicFollow);
  // print("\n" + other);
  // other = await doMemoAction("Escuchame wow increible no me digas ke veina naguara vergacion", MemoCode.TopicPostMessage, "zxcvsadf");
  // print("\n" + other);
  // other = await doMemoAction("Bitcoin+Map", MemoCode.TopicFollowUndo);
  // print("\n" + other);
}

Future<String> doMemoAction (String memoMessage, MemoCode memoAction, String memoTopic) async {
  print("\n" + memoAction.opCode + "\n" + memoAction.name);
  /// connect to electrum service with websocket
  /// please see `services_examples` folder for how to create electrum websocket service
  final service = await ElectrumWebSocketService.connect(
      "wss://" + mainnetServers[2] + ":50004");

  /// create provider with service
  final provider = ElectrumProvider(service);

  /// network
  const network = BitcoinCashNetwork.mainnet;

  /// initialize private key
  final privateKey = ECPrivate.fromWif("5HtpWVLipP5iKskfrhZLcxveVV39JZpiMGQseYRepRDUPGp97sU", netVersion: network.wifNetVer);

  /// public key
  final publicKey = privateKey.getPublic();

  /// Derives a P2PKH address from the given public key and converts it to a Bitcoin Cash address
  /// for enhanced accessibility within the network.
  final p2pkhAddress =
      BitcoinCashAddress.fromBaseAddress(publicKey.toAddress());

  /// Reads all UTXOs (Unspent Transaction Outputs) associated with the account.
  /// We does not need tokens utxo and we set to false.
  final elctrumUtxos =
      await provider.request(ElectrumRequestScriptHashListUnspent(
    scriptHash: p2pkhAddress.baseAddress.pubKeyHash(),
    includeTokens: false,
  ));

  /// Converts all UTXOs to a list of UtxoWithAddress, containing UTXO information along with address details.
  final List<UtxoWithAddress> utxos = elctrumUtxos
      .map((e) => UtxoWithAddress(
          utxo: e.toUtxo(p2pkhAddress.type),
          ownerDetails: UtxoAddressDetails(
              publicKey: publicKey.toHex(), address: p2pkhAddress.baseAddress)))
      .toList();

  /// dump all the SLP transactions
  for(UtxoWithAddress utxo in utxos.clone()) {
    if (utxo.utxo.value.toSignedInt32 == 546)
      utxos.remove(utxo);
  }

  /// som of utxos in satoshi
  final sumOfUtxo = utxos.sumOfUtxosValue();
  if (sumOfUtxo == BigInt.zero) {
    return "No UTXO funds found";
  }

  var fee = BtcUtils.toSatoshi("0.000004");
  final bchTransaction = MemoTransactionBuilder(
    outPuts: [
      /// change input (sumofutxos - spend)
      BitcoinOutput(
        address: p2pkhAddress.baseAddress,
        value: sumOfUtxo -
            fee,
      )
    ],
    fee: fee,
    network: network,
    utxos: utxos,
    memo: memoMessage,
      memoCode: memoAction,
      memoTopic: memoTopic
  );
  final transaaction =
      bchTransaction.buildTransaction((trDigest, utxo, publicKey, sighash) {
    return privateKey.signECDSA(trDigest, sighash: sighash);
  });

  /// transaction ID
  transaaction.txId();
  print(transaaction.txId());

  /// for calculation fee
  transaaction.getSize();

  /// raw of encoded transaction in hex
  final transactionRaw = transaaction.toHex();

  /// send transaction to network
  await provider.request(
      ElectrumRequestBroadCastTransaction(transactionRaw: transactionRaw),timeout: const Duration(seconds: 30));
  return "Success";

  /// done! check the transaction in block explorer
  ///  https://chipnet.imaginary.cash/tx/9e534f8a64f76b1af5ccf2522392697f2242fd215206a458cfe286bca4a3ec0a
}
