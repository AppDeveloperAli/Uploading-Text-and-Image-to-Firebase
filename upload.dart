import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostsSender extends StatefulWidget {
  const PostsSender({super.key});

  @override
  State<PostsSender> createState() => _PostsSenderState();
}

class _PostsSenderState extends State<PostsSender> {
  // Get Text from Textfield through these controller
  TextEditingController title_controller = TextEditingController();
  TextEditingController desc_controller = TextEditingController();

  /// Variables
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            height: 200,
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: imageFile == null
                  ? Image.asset('assets/img/add.png')
                  : Image.file(imageFile!),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                getDilogueBox(context, 'Pick Profile Image', 'Want to open ?');
              },
              child: Text('Pick Image')),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: TextField(
              controller: title_controller,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                hintText: 'Write something...',
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: TextField(
              controller: desc_controller,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                hintText: 'Write something...',
                hintStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ElevatedButton(
                onPressed: uploadDate,
                child: Text('Upload Data'),
              ))
        ]),
      ),
    );
  }

  Future uploadDate() async {
    late UploadTask uploadTask;

    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please Pick a Image for your Post First..")));
    } else if (title_controller.text.isEmpty || desc_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Fill All Fields First..")));
    } else {
      final path = 'Posts_Images/${imageFile!.path.split('/').last}';
      final file = File(imageFile!.path);

      String? imageAddress;

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);

      final snapshot = await uploadTask.whenComplete(() {});

      imageAddress = await snapshot.ref.getDownloadURL();

      Map<String, dynamic> date = {
        "Post_Title": title_controller.text,
        "Post_Description": desc_controller.text,
        "Post_Image_Address": imageAddress
      };

      FirebaseFirestore.instance.collection("Posts").add(date);

      setState(() {
        title_controller.clear();
        desc_controller.clear();
        imageFile == null;
      });
    }
  }

  Future<void> getDilogueBox(
    BuildContext context,
    String title,
    String brief,
  ) async {
    return showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(brief),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Camera',
                style: const TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                _getFromCamera();
              },
            ),
            TextButton(
              child: Text(
                'Gallery',
                style: const TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                _getFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  /// Get from gallery
  _getFromGallery() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
}
