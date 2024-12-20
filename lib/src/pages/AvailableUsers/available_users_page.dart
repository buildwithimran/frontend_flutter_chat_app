import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class AvailableUsersPage extends StatefulWidget {
  const AvailableUsersPage({super.key});
  @override
  State<AvailableUsersPage> createState() => _AvailableUsersPage();
}

class _AvailableUsersPage extends State<AvailableUsersPage> {
  // Services
  var appService = AppService();

  // variables
  var participantUsers = [];
  var filteredParticipantUsers = [];
  bool loader = true;

  // Functions

  sendInvitation(id) {
    showLoader(context, 'Just a moment ...');
    var formObj = {"to": id};
    appService.sentInvitation(formObj).then((result) {
      unFocus(context);
      if (result['status'] == 'success') {
        showToast(context, 3, result['message']);
        pop(context);
        fetchParticipants();
      } else {
        pop(context);
        showToast(context, 3, result['message']);
      }
    });
  }

  fetchParticipants() async {
    appService.getParticipants().then((result) {
      if (result['status'] == 'success') {
        participantUsers = result['data'];
        filteredParticipantUsers = result['data'];
        loader = false;
        if (mounted) setState(() {});
      } else {
        print("Something went wrong");
        loader = false;
        if (mounted) setState(() {});
      }
    });
  }

  onSearchTextChanged(String query) {
    query = query.toLowerCase();
    if (query.isEmpty) {
      filteredParticipantUsers = participantUsers;
    } else {
      filteredParticipantUsers = participantUsers
          .where((item) => item.values.any((value) =>
              value != null && value.toString().toLowerCase().contains(query)))
          .toList();
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchParticipants();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          centerTitle: true,
          title: Text(
            'Participants',
            style: TextStyle(fontFamily: 'psb', fontSize: apptit),
          ),
        ),
        body: SingleChildScrollView(
          child: loader
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: CircularProgressIndicator(
                      backgroundColor: lightColor,
                      color: primaryColor,
                    ),
                  ),
                )
              : Column(
                  children: [
                    Visibility(
                      visible: filteredParticipantUsers.isEmpty,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
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
                                "No Participant Available",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'psb',
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: filteredParticipantUsers.isNotEmpty,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          itemCount: participantUsers.length,
                          itemBuilder: (context, index) {
                            var participant = participantUsers[index];
                            return Card(
                              child: ListTile(
                                leading: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          Config.baseURL +
                                              participant['avatar'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(participant["fullName"],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'psb',
                                        color: primaryColor)),
                                subtitle: participant["phone"].isNotEmpty
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            "${participant["countryCode"] + ' ' + participant["phone"]}",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: greyColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : participant["email"].isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Text(
                                                "${participant["email"]}",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: greyColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                trailing: TextButton(
                                  onPressed: () {
                                    sendInvitation(participant['_id']);
                                  },
                                  child: Text(
                                    'SEND',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
