import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emplyee_attendance_system/model/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenWidth = 0;
  double screenHeight = 0;

  Color primary = const Color(0xff2196f3);

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String birth = "Date of Birth";

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref().child("${User.employeeId.toLowerCase()}_profilepic.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
        User.profilePicLink = value;
      });

      await FirebaseFirestore.instance.collection("Employee").doc(User.id).update({
        'profilePic' : value,
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                pickUploadProfilePic();
              },
              child: Container(
                margin: EdgeInsets.only(top: 80, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePicLink == " " ? Icon(Icons.person,
                    color: Colors.white,
                    size: 80,
                  ) : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(User.profilePicLink)
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Employee ${User.employeeId}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 24,),
            User.canEdit ? textField("First Name", "First Name", firstNameController) :field("First Name", User.firstName),
            User.canEdit ? textField("Last Name", "Last Name", lastNameController) : field("Last Name", User.lastName),
            User.canEdit ? GestureDetector(
              onTap: (){
                showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now()
                ).then((value) {
                  setState(() {
                   birth = DateFormat("MM/dd/yyyy").format(value!);
                  });
                });
              },
              child: field("Date Of Birth", birth)
            ) : field("Date Of Birth", User.birthDate),
            User.canEdit ? textField("Address", "Address", addressController) : field("Address", User.address),
            User.canEdit ? GestureDetector(
              onTap: () async {
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String dateOfBirth = birth;
                String address = addressController.text;

                if(User.canEdit) {
                  if(firstName.isEmpty){
                    showSnackBar("Please Enter Your First Name!");
                  }
                  else if(lastName.isEmpty){
                    showSnackBar("Please Enter Your Last Name!");
                  }
                  else if(dateOfBirth.isEmpty){
                    showSnackBar("Please Enter Your Date Of Birth!");
                  }
                  else if(address.isEmpty){
                    showSnackBar("Please Enter Your Address!");
                  }
                  else{
                    await FirebaseFirestore.instance.collection("Employee").doc(User.id).update(
                      {
                        'firstName' : firstName,
                        'lastName' : lastName,
                        'dateOfBirth' : dateOfBirth,
                        'address' : address,
                        'canEdit' : false,
                      }
                    ).then((value) {
                      setState(() {
                        User.canEdit = false;
                        User.firstName = firstName;
                        User.lastName = lastName;
                        User.birthDate = dateOfBirth;
                        User.address = address;
                      });
                    });
                  }
                }
                else{
                  showSnackBar("You can't edit anymore, please contact support team!");
                }
              },
              child: Container(
                height: kToolbarHeight,
                width: screenWidth,
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: primary,
                ),
                child: Center(
                  child: Text(
                    "SAVE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ) : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget field(String title, String text){
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title, style: TextStyle(
            color: Colors.black87,
          ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.black54,
              )
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(String hint, String title, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title, style: TextStyle(
            color: Colors.black87,
          ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Colors.black54
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            text,
          ),
        ),
    );
  }

}
