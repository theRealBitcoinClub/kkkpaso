import 'dart:developer';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

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
  // await print("\n\n" + doMemoAction("ProfilePostMessage", MemoCode.ProfilePostMessage));
  // print("\n${await doMemoAction("IMG1 https://imgur.com/eIEjcUe", MemoCode.ProfilePostMessage,"")}");
  // print("\n${await doMemoAction("IMG2 https://i.imgur.com/eIEjcUe.jpeg", MemoCode.ProfilePostMessage,"")}");
  // print("\n${await doMemoAction("YT1 https://youtu.be/dQw4w9WgXcQ", MemoCode.ProfilePostMessage,"")}");
  print("\n${await doMemoAction("YT2 https://www.youtube.com/watch?v=dQw4w9WgXcQ", MemoCode.ProfilePostMessage,"")}");
  // var other = await doMemoAction("https://imgur.com/eIEjcUe", MemoCode.SetProfileImgUrl, "");
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

  var fee = BtcUtils.toSatoshi("0.000003");
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
