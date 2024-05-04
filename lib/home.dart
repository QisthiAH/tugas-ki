import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';

enum CryptoOperation { encrypt, decrypt }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController plainTextController;
  late TextEditingController keyController;
  CryptoOperation operation = CryptoOperation.encrypt;

  @override
  void initState() {
    super.initState();
    plainTextController = TextEditingController();
    keyController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text(
          'Encrypt Decrypt Demo',
          style: TextStyle(color: Color(0xffbb86fc)),
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: plainTextController,
              decoration: const InputDecoration(
                labelText: 'Text',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff6200ee))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff6200ee))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
              maxLength: 16,
            ),
            ListTile(
              title: const Text('Encrypt'),
              leading: Radio(
                value: CryptoOperation.encrypt,
                groupValue: operation,
                onChanged: (CryptoOperation? value) {
                  setState(() {
                    operation = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Decrypt'),
              leading: Radio(
                value: CryptoOperation.decrypt,
                groupValue: operation,
                onChanged: (CryptoOperation? value) {
                  setState(() {
                    operation = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: executeCryptoOperation,
              child: Text(operation == CryptoOperation.encrypt ? 'Encrypt' : 'Decrypt'),
            ),
          ],
        ),
      ),
    );
  }

// fungsi untuk menampilkan pop up jika key yang diinput kurang dari 16 karakterer
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Error')),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

// fungsi yang digunakan oleh radio button untuk memilih perlakuan mana yang akan dilakukan
  void executeCryptoOperation() {
    final text = plainTextController.text;
    final keyString = keyController.text;
    final key = getKeyFromUtf8String(keyString);

    if (keyString.length != 16) {
      return showErrorDialog('Key must be exactly 16 characters long');
    }

    final iv = encrypt.IV.fromUtf8('1111111111111111');
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    String resultText = '';

    if (operation == CryptoOperation.encrypt) {
      final encrypted = encrypter.encrypt(text, iv: iv);
      resultText = encrypted.base64;
    } else {
      final encryptedText = plainTextController.text;
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      resultText = decrypted;
    }

    showResultDialog(resultText);
  }

//fungsi untuk pop up hasil dari enkripsi atau dekripsi
  void showResultDialog(String resultText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(operation == CryptoOperation.encrypt ? 'Encrypted Text' : 'Decrypted Text')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(resultText),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: resultText));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
                  },
                  child: const Text('Copy'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  encrypt.Key getKeyFromUtf8String(String keyString) {
    final keyBytes = utf8.encode(keyString);
    return encrypt.Key(Uint8List.fromList(keyBytes));
  }

  @override
  void dispose() {
    plainTextController.dispose();
    keyController.dispose();
    super.dispose();
  }
}
