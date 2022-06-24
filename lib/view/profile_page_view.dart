import 'dart:io';
import 'package:firebase_assignment/constants/color_constants.dart';
import 'package:firebase_assignment/constants/firestore_constants.dart';
import 'package:firebase_assignment/constants/text_field_constants.dart';
import 'package:firebase_assignment/models/chat_user.dart';
import 'package:firebase_assignment/viewModel/profile_view_model.dart';
import 'package:firebase_assignment/widgets/loading_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController? displayNameController;
  TextEditingController? aboutMeController;
  TextEditingController? phoneController = TextEditingController();

  late String currentUserId;
  String id = '';
  String displayName = '';
  String photoUrl = '';
  String phoneNumber = '';
  String aboutMe = '';
  bool isLoading = false;
  File? avatarImageFile;
  late ProfileViewModel profileViewModel;
  final FocusNode focusNodeNickname = FocusNode();

  @override
  void initState() {
    super.initState();
    profileViewModel = context.read<ProfileViewModel>();
    readLocal();
  }

  void readLocal() {
    id = profileViewModel.getPrefs(FirestoreConstants.id) ?? "";
    displayName =
        profileViewModel.getPrefs(FirestoreConstants.displayName) ?? "";
    photoUrl = profileViewModel.getPrefs(FirestoreConstants.photoUrl) ?? "";
    phoneNumber =
        profileViewModel.getPrefs(FirestoreConstants.phoneNumber) ?? "";
    aboutMe = profileViewModel.getPrefs(FirestoreConstants.aboutMe) ?? "";
    displayNameController = TextEditingController(text: displayName);
    aboutMeController = TextEditingController(text: aboutMe);
    phoneController = TextEditingController(text: phoneNumber);
    setState(() {});

  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery)
        .catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = displayName.split(' ')[0];
    print(displayName.split(' ')[0]);
    print('HHHSHSHSHSHHHHHSHSSHSH');
    UploadTask uploadTask =
        profileViewModel.uploadImageFile(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      ChatUser updateInfo = ChatUser(
          id: id,
          photoUrl: photoUrl,
          displayName: displayName,
          phoneNumber: phoneNumber,
          aboutMe: aboutMe);
      profileViewModel
          .updateFirestoreData(
              FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((value) async {
        await profileViewModel.setPrefs(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
      print('File cannot be uploaded');
    }
  }

  void updateFirestoreData() {
    focusNodeNickname.unfocus();
    setState(() {
      isLoading = true;
    });
    ChatUser updateInfo = ChatUser(
        id: id,
        photoUrl: photoUrl,
        displayName: displayName,
        phoneNumber: phoneNumber,
        aboutMe: aboutMe);
    profileViewModel
        .updateFirestoreData(
            FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((value) async {
      await profileViewModel.setPrefs(
          FirestoreConstants.displayName, displayName);
      await profileViewModel.setPrefs(
          FirestoreConstants.phoneNumber, phoneNumber);
      await profileViewModel.setPrefs(
        FirestoreConstants.photoUrl,
        photoUrl,
      );
      await profileViewModel.setPrefs(FirestoreConstants.aboutMe, aboutMe);

      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'UpdateSuccess');
      if (mounted) {
        Navigator.pop(context);
      }
    }).catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text(
          AppConstants.profileTitle,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: getImage,
                    child: Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20),
                      child: avatarImageFile == null
                          ? photoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, object, stackTrace) {
                                      return const Icon(
                                        Icons.account_circle,
                                        size: 90,
                                        color: AppColors.greyColor,
                                      );
                                    },
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }
                                      return SizedBox(
                                        width: 90,
                                        height: 90,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.grey,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: AppColors.greyColor,
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.file(
                                avatarImageFile!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Name',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: AppColors.aapnaGreen,
                        ),
                      ),
                      TextFormField(
                        decoration: kTextInputDecoration.copyWith(
                            hintText: 'Write your Name'),
                        controller: displayNameController,
                        onChanged: (value) {
                          displayName = value;
                        },
                        focusNode: focusNodeNickname,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Name is required..';
                          }
                          return null;
                        },
                      ),
                      vertical15,
                      const Text(
                        'About Me...',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: AppColors.aapnaGreen),
                      ),
                      TextFormField(
                        decoration: kTextInputDecoration.copyWith(
                            hintText: 'Write about yourself...'),
                        controller: aboutMeController,
                        onChanged: (value) {
                          aboutMe = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'About me is required..';
                          }
                          return null;
                        },
                      ),
                      vertical15,
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: AppColors.aapnaGreen,
                        ),
                      ),
                      IntlPhoneField(
                        decoration: kTextInputDecoration.copyWith(
                          hintText: "Input Phone Number"
                        ),
                        initialCountryCode: 'IN',
                        controller: phoneController,
                        onChanged: (phone) {
                          print(phone.completeNumber);
                          phoneNumber=phone.completeNumber;
                          setState((){});
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        updateFirestoreData();
                      }
                      else {
                        Fluttertoast.showToast(msg: 'Fill all required fields !');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.aapnaGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Update Info'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              child: isLoading ? const LoadingView() : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
