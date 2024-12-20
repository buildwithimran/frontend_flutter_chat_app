import 'package:chat_app/src/pages/Chat/chat_page.dart';
import 'package:chat_app/src/pages/AvailableUsers/available_users_page.dart';
import 'package:chat_app/src/pages/Widgets/photo_view.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chat_app/src/helper/helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatPage extends StatefulWidget {
  ChatPage();
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Services
  var appService = AppService();

  // Variables
  TextEditingController searchController = TextEditingController();
  List friends = [];
  bool friendsLoader = false;
  List invitations = [];
  bool invitationLoader = false;
  bool isFilteredApplied = false;
  List<bool> isFavList = [];

  // Functions
  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchMyInvitation();
  }

  fetchFriends() async {
    friendsLoader = true;
    if (mounted) setState(() {});
    appService.getMyFriends().then((result) {
      if (result['status'] == 'success') {
        if (result['data'] != null) {
          friends = result['data'];
          isFavList = List.generate(friends.length, (index) => false);
        }
      }
      friendsLoader = false;
      if (mounted) setState(() {});
    });
  }

  fetchMyInvitation() {
    invitationLoader = true;
    if (mounted) setState(() {});
    appService.myInvitations().then((response) {
      invitationLoader = false;
      if (response['status'] == 'success') {
        invitations = response['data'];
      }
      if (mounted) setState(() {});
    });
  }

  confirmationInvitationDialog(BuildContext context, invitationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Are you sure?",
              style: TextStyle(color: primaryColor, fontFamily: 'pr')),
          content: const Text("You want to accept a invitation?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                acceptInvitation(invitationId);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  acceptInvitation(invitationId) {
    if (mounted) setState(() {});
    var formObj = {"invitationId": invitationId};
    appService.acceptInvitation(formObj).then((response) {
      if (response['status'] == 'success') {
        pop(context);
        fetchMyInvitation();
        fetchFriends();
      } else {
        showToast(context, 3, "Something went going wrong");
      }
      if (mounted) setState(() {});
    });
  }

  adToFavUser(likeUserId, index) {
    appService.adToFavUser({"likeUserId": likeUserId}).then((value) {
      isFavList[index] = true;
      if (mounted) setState(() {});
    });
  }

  removeToFavUser(likeUserId, index) {
    appService.removeToFavUser({"likeUserId": likeUserId}).then((value) {
      isFavList[index] = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Live Chat',
            style: TextStyle(fontFamily: 'psb', fontSize: apptit),
          ),
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: primaryColor,
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                labelColor: lightColor,
                unselectedLabelColor: primaryLightColor,
                indicatorColor: primaryColor,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                labelStyle: const TextStyle(fontFamily: 'pb'),
                tabs: const [
                  Tab(text: "Messages"),
                  Tab(text: "Invitations"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [chatsTab(), invitationsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatsTab() {
    var refresh = RefreshController(initialRefresh: false);

    onRefresh() async {
      await fetchFriends();
      refresh.refreshCompleted();
    }

    onLoading() async {
      await fetchFriends();
      refresh.loadComplete();
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: refresh,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: GestureDetector(
        onTap: () => unFocus(context),
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: friendsLoader == true
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: backgroundColor,
                    color: primaryColor,
                  ),
                )
              : Column(
                  children: [
                    friends.isEmpty && isFilteredApplied == false
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.user_octagon,
                                    size: 70,
                                    color: primaryColor,
                                  ),
                                  Text(
                                    "No Chat Found",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'psb',
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "Click the + button to send invitation",
                                    style: TextStyle(
                                      fontFamily: 'pr',
                                      fontSize: 14,
                                      color: greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Visibility(
                                visible: friends.isEmpty &&
                                    isFilteredApplied == true,
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.user_octagon,
                                        size: 70,
                                        color: primaryColor,
                                      ),
                                      Text(
                                        "No Friends Found",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'psb',
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Text(
                                        "Click the + button to create a new Invitation",
                                        style: TextStyle(
                                          fontFamily: 'pr',
                                          fontSize: 14,
                                          color: greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: p, vertical: 0),
                                height: friends.length * 110,
                                child: ListView(
                                  children:
                                      List.generate(friends.length, (index) {
                                    var friend = friends[index];
                                    if (friend['favourite'] != null) {
                                      isFavList[index] = true;
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ChatDetailPage(
                                                    personInfo: friend),
                                          ),
                                        ).then((value) => {fetchFriends()});
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        margin:
                                            const EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                            color: lightColor,
                                            border: Border(
                                              bottom:
                                                  BorderSide(color: fillColor),
                                            )),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(5),
                                          leading: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ContainerPhotoView(
                                                    imageUrl: friend['friend']
                                                        ['avatar'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: CachedNetworkImage(
                                                width: 55,
                                                height: 55,
                                                imageUrl: Config.baseURL +
                                                    friend['friend']['avatar'],
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            friend['friend']['fullName']
                                                .toString()
                                                .toTitleCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontFamily: 'psb',
                                                fontSize: 16),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formatUSPhoneNumber(
                                                    friend['friend']
                                                            ['countryCode'] +
                                                        ' ' +
                                                        friend['friend']
                                                            ['phone']),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              if (friend['latestMessage'] !=
                                                  null)
                                                Text(
                                                  "Last Message: ${friend['latestMessage']['message']}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: greyColor,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              if (isFavList[index] == false) {
                                                adToFavUser(
                                                    friend['friend']['_id'],
                                                    index);
                                              } else {
                                                removeToFavUser(
                                                    friend['friend']['_id'],
                                                    index);
                                              }
                                              if (mounted) setState(() {});
                                            },
                                            child: Icon(
                                              isFavList[index]
                                                  ? Iconsax.heart
                                                  : OctIcons.heart_16,
                                              color: isFavList[index]
                                                  ? redColor
                                                  : primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          )
                  ],
                ),
          floatingActionButton: Container(
            margin: const EdgeInsets.all(5),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const AvailableUsersPage(),
                  ),
                );
              },
              backgroundColor: primaryColor,
              child: Icon(
                FontAwesomeIcons.plus,
                color: lightColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget invitationsTab() {
    var refresh = RefreshController(initialRefresh: false);

    onRefresh() async {
      await fetchMyInvitation();
      refresh.refreshCompleted();
    }

    onLoading() async {
      await fetchMyInvitation();
      refresh.loadComplete();
    }

    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      controller: refresh,
      onRefresh: onRefresh,
      onLoading: onLoading,
      child: invitationLoader == true
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: backgroundColor,
                color: primaryColor,
              ),
            )
          : invitations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.user_octagon,
                        size: 70,
                        color: primaryColor,
                      ),
                      Text(
                        "No Invitation Found",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'psb',
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: invitations.length,
                  itemBuilder: (context, index) {
                    var invitation = invitations[index];
                    return Card(
                      margin: EdgeInsets.all(p),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(Config.baseURL +
                                  invitation['senderUserId']['avatar']),
                            ),
                            title: Text(
                              invitation['senderUserId']['fullName'],
                              style: const TextStyle(fontFamily: 'psb'),
                            ),
                            subtitle: Text(
                              invitation['senderUserId'] != null
                                  ? (invitation['senderUserId']['phone'] !=
                                              null &&
                                          invitation['senderUserId']['phone']
                                              .isNotEmpty
                                      ? (invitation['senderUserId']
                                                  ['countryCode'] ??
                                              '') +
                                          invitation['senderUserId']['phone']
                                      : (invitation['senderUserId']['email'] !=
                                                  null &&
                                              invitation['senderUserId']
                                                      ['email']
                                                  .isNotEmpty
                                          ? invitation['senderUserId']['email']
                                          : ''))
                                  : 'Unknown sender',
                              style: const TextStyle(fontFamily: 'psb'),
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            onTap: () {
                              confirmationInvitationDialog(
                                  context, invitation['_id']);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                'Time: ${datePipe(invitation['createdAt'])}'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
