import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kisanseva/models/rent_tools_model.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:cloud_firestore/cloud_firestore.dart";


class AddRentToolsCtrl extends GetxController {
  RentToolsModel rentToolsModel = RentToolsModel();
  String picDownloadUrl = '';
  var logger = Logger(printer: PrettyPrinter());
  final isLoading = false.obs;
  late User firebaseUser;
  late String ownerContactInfo;
  // Firestore firestore = FirebaseFirestore.instance;
  String contact = "";
  Future<dynamic> postImage(File imageFile) async {
    logger.d('inside postImage');

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('rentTools/$fileName');
    // StorageUploadTask uploadTask = reference.putData(
    //     (await imageFile.getByteData(quality: 25)).buffer.asUint8List());
    UploadTask uploadTask = storageReference.putFile(imageFile);
    print('here 2');
    TaskSnapshot storageTaskSnapshot = await uploadTask;
    print(storageTaskSnapshot.ref.getDownloadURL());
    print('here 3');

    // storageReference.getDownloadURL().then((fileURL) {
    //   // setState(() {
    //   rentToolsModel.toolImage = fileURL;
    //   // });
    // });
    logger.d("toolImage url=${rentToolsModel.toolImage}");
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  getCurrentUser() async {
    final value = FirebaseAuth.instance.currentUser;
    contact = value?.phoneNumber ?? "";
    rentToolsModel.ownerContactInfo = (contact);
  }

  // getOwnerInfoFromFirestore() async {
  //   //return Firestore.instance.collection('users').document(firebaseUser.uid);

  //   await Firestore.instance
  //       .collection('users')
  //       .document(firebaseUser.uid)
  //       .snapshots()
  //       .forEach((element) {
  //     contact = element.data["phno"];
  //   });
  //   // =int.parse(contact);
  // }

  addRentTools(imageFile) async {
    // isLoading(true);
    Get.dialog(
      Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 300.0),
          child: Center(
            child: Column(
              // height: 500,
              children: [
                Center(child: Text("Uploading... Please wait")),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
    await postImage(imageFile)
        .then((value) => rentToolsModel.toolImage = value);

    logger.d("inside addRentTools ${rentToolsModel.toJson()}");
    await getCurrentUser();
    // await getOwnerInfoFromFirestore();
    await FirebaseFirestore.instance
        .collection("rentTools")
        .doc()
        .set(rentToolsModel.toJson());
    // await crudOp.createPost(
    //   collectionName: 'examsResources',
    //   data: _examModel.toJson(),
    // );
    Get.back();
    // isLoading(false);
    Get.back();
  }
}