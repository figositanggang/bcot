import 'package:bcot/features/bcot/add_bcot_screen.dart';
import 'package:bcot/features/auth/login_screen.dart';
import 'package:bcot/features/comment/comments.dart';
import 'package:bcot/firebase/firebase_auth_helper.dart';
import 'package:bcot/firebase/firebase_firestore_helper.dart';
import 'package:bcot/models/bcot_model.dart';
import 'package:bcot/features/user/user_provider.dart';
import 'package:bcot/features/user/current_user_screen.dart';
import 'package:bcot/models/user_model.dart';
import 'package:bcot/utils/custom_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final currentUser = FirebaseAuth.instance.currentUser!;
  final firebaseFirestore = FirebaseFirestore.instance;

  late UserProvider userProvider;

  late Future<void> getUser;

  ScrollController scrollController = ScrollController();

  int limit = 10;

  // ! INIT STATE
  @override
  void initState() {
    super.initState();

    userProvider = Provider.of<UserProvider>(context, listen: false);

    getCurrentUser();
  }

  // ! GET CURRENT USER DATA
  void getCurrentUser() {
    getUser = FirebaseFirestoreHelper.GetCurrentUser(
      currentUserId: currentUser.uid,
      userProvider: userProvider,
    );
  }

  // ! DISPOSE
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: getUser,
      builder: (context, snapshot) {
        // ? Loading User
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Material();
        }

        // ? User Logged In
        return SafeArea(
          child: Scaffold(
            key: scaffoldKey,
            // @ Drawer
            drawer: Drawer(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: 250,
                        child: DrawerHeader(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.read<UserProvider>().user!.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                  "@${context.read<UserProvider>().user!.username}"),
                            ],
                          ),
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(.75),
                                BlendMode.darken,
                              ),
                              image: NetworkImage(
                                  context.read<UserProvider>().user!.photoUrl),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: FaIcon(FontAwesomeIcons.solidUser),
                            title: Text(
                              "Akun",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            minVerticalPadding: 25,
                            onTap: () async {
                              Navigator.push(
                                context,
                                CustomRoute(UserScreen(
                                  userId: currentUser.uid,
                                )),
                              );

                              await Future.delayed(Duration(milliseconds: 100));
                              try {
                                scaffoldKey.currentState!.closeDrawer();
                              } catch (e) {}
                            },
                          ),
                          Divider(
                            height: 0,
                            color: Colors.white.withOpacity(.1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.rightFromBracket,
                      color: Colors.red,
                    ),
                    title: Text(
                      "Keluar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => MyAlertDialog(
                          content: "Yaking ingin keluar",
                          onYes: () async {
                            try {
                              showDialog(
                                context: context,
                                builder: (context) => Material(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                              await Future.delayed(Duration(seconds: 1));

                              await FirebaseAuthHelper.signOut(userProvider);

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  CustomRoute(SignInScreen()),
                                  (route) => false);
                            } catch (e) {}
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            drawerEdgeDragWidth: size.width / 2.5,
            body: NestedScrollView(
              controller: scrollController,
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // @ App Bar
                  SliverAppBar(
                    scrolledUnderElevation: 0,
                    toolbarHeight: kToolbarHeight + 10,
                    snap: true,
                    floating: true,
                    stretch: true,
                    leading: IconButton(
                      onPressed: () {
                        scaffoldKey.currentState!.openDrawer();
                      },
                      icon: CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(
                            context.watch<UserProvider>().user!.photoUrl),
                      ),
                    ),
                    title: GestureDetector(
                      onTap: () async {
                        await scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Text("BCot"),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CustomRoute(
                              AddBCotScreen(
                                currentUserId: userProvider.user!.userId,
                                username: userProvider.user!.username,
                                photoUrl: userProvider.user!.photoUrl,
                              ),
                            ),
                          );
                        },
                        icon: FaIcon(
                          FontAwesomeIcons.pen,
                          size: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ];
              },

              // @ BODY
              body: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 1));
                  setState(() {});
                },
                // @ List Bcot
                child: FirestoreListView(
                  query: FirebaseFirestoreHelper.GetBcotQuery(),
                  pageSize: 10,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  loadingBuilder: (context) {
                    return Center(child: CircularProgressIndicator());
                  },
                  itemBuilder: (context, snapshot) {
                    final bcot = BCotModel.fromSnapshot(snapshot);

                    // @ BcotCard
                    return BCotCard(
                      currentUserId: context.watch<UserProvider>().user!.userId,
                      bcotModel: bcot,
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomRoute(Comments(bcot: bcot)),
                        );
                      },
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text("Ada Kesalahan..."),
                    );
                  },
                  emptyBuilder: (context) {
                    return SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: Center(
                          child: Text("Belum ada orang yang ngebacot"),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
