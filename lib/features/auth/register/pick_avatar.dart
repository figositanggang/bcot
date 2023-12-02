// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bcot/features/auth/register/register_provider.dart';
import 'package:bcot/firebase/firebase_auth_helper.dart';
import 'package:bcot/main.dart';
import 'package:bcot/utils/custom_widgets.dart';

class PickAvatar extends StatefulWidget {
  const PickAvatar({super.key});

  @override
  State<PickAvatar> createState() => _PickAvatarState();
}

class _PickAvatarState extends State<PickAvatar> {
  List avatars = [
    "https://res.cloudinary.com/unlinked/image/upload/v1701104680/BCot/avatars/3d-illustration-person-with-sunglasses_23-2149436188_cnwxwv.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104684/BCot/avatars/3d-illustration-human-avatar-profile_23-2150671142_tkpwui.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104701/BCot/avatars/3d-illustration-human-avatar-profile_23-2150671132_bwykkc.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104709/BCot/avatars/3d-illustration-human-avatar-profile_23-2150671126_lx5o33.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104718/BCot/avatars/3d-illustration-human-avatar-profile_23-2150671134_hxwlvu.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104733/BCot/avatars/3d-illustration-human-avatar-profile_23-2150671165_vcugem.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104764/BCot/avatars/3d-illustration-human-avatar-profile_23-2150671120_zr7ebv.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104771/BCot/avatars/3d-illustration-person-with-pink-hair_23-2149436186_jquedv.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104791/BCot/avatars/3d-illustration-person-with-punk-hair-jacket_23-2149436198_edpzxh.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104812/BCot/avatars/3d-rendering-avatar_23-2150833572_m7sfky.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104823/BCot/avatars/3d-rendering-avatar_23-2150833542_e1s1um.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104871/BCot/avatars/3d-rendering-avatar_23-2150833556_cdj2m9.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104882/BCot/avatars/3d-rendering-avatar_23-2150833570_klmk80.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701104902/BCot/avatars/3d-rendering-avatar_23-2150833558_qnbxpg.jpg",
    "https://res.cloudinary.com/unlinked/image/upload/v1701105210/BCot/avatars/3d-rendering-avatar_23-2150833548_qvgqp7.jpg",
  ];

  int selectedIndex = 0;

  // ! Sign Up
  Future<void> signUp({
    required String email,
    required String username,
    required String name,
    required String password,
    required String photoUrl,
  }) async {
    showDialog(
      context: context,
      builder: (context) => Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    String res = await FirebaseAuthHelper.signUp(
      email: email,
      username: username,
      name: name,
      password: password,
      photoUrl: photoUrl,
    );

    if (res == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil")),
      );

      Navigator.pushAndRemoveUntil(
          context, CustomRoute(AuthState()), (route) => false);
    }
    if (res == 'weak-password') {
      ScaffoldMessenger.of(context).showSnackBar(
        MySnackBar("Password masih lemah"),
      );
    } else if (res == "email-already-in-use") {
      ScaffoldMessenger.of(context)
          .showSnackBar(MySnackBar("Email telah digunakan"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerProv = Provider.of<RegisterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Avatar"),
        actions: [
          TextButton(
            onPressed: () {
              signUp(
                email: registerProv.email.text.trim(),
                username: registerProv.username.text.trim(),
                name: registerProv.name.text.trim(),
                password: registerProv.password.text.trim(),
                photoUrl: avatars[selectedIndex],
              );
            },
            child: Text("Buat Akun"),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemCount: avatars.length,
        itemBuilder: (context, index) {
          return _PickAvatar(
            index: index,
            avatarUrl: avatars[index],
            isSelected: selectedIndex == index,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class _PickAvatar extends StatelessWidget {
  final int index;
  final String avatarUrl;
  final void Function() onTap;
  bool isSelected = false;

  _PickAvatar({
    required this.index,
    required this.avatarUrl,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: DecorationImage(
          image: NetworkImage(avatarUrl),
          fit: BoxFit.cover,
          colorFilter: !isSelected
              ? ColorFilter.mode(Colors.black.withOpacity(.5), BlendMode.darken)
              : null,
        ),
      ),
      child: InkWell(
        onTap: onTap,
      ),
    );
  }
}
