import 'package:chainchat/pages/chat_page.dart';
import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  final List<String> contacts;
  final String phrase;
  final String ed25519Address;
  final String privateKey;
  ContactsPage({Key? key, required this.contacts,required this.phrase,required this.ed25519Address,required this.privateKey}) : super(key: key);

  // Check if we need to insert a label at the current index
  bool shouldInsertLabel(int index, List<String> sortedContacts) {
    if (index == 0) return true; // Always insert the first label at the start

    // Get the first character of the current and previous contact
    String currentStart = sortedContacts[index].substring(0, 3);
    String previousStart = sortedContacts[index - 1].substring(0, 3);

    // If the start character of the current contact is different from the previous one, insert a new label
    return currentStart != previousStart;
  }

  // Format the address to show only the first 7 and last 4 characters with ellipsis in between
  String formatAddress(String address) {
    if (address.length <= 11) return address; // If the address is too short, no need to format
    return '${address.substring(0, 7)}...${address.substring(address.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    List<String> sortedContacts = List.from(contacts)..sort();
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Group Chat'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GroupChatPage()),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedContacts.length,
              itemBuilder: (BuildContext context, int index) {
                // Determine if a new label should be inserted at this position
                if (shouldInsertLabel(index, sortedContacts)) {
                  return Column(
                    children: [
                      Container(
                        color: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        child: Text(
                          sortedContacts[index].substring(0, 3),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300], // Placeholder background color for avatar
                          child: Text(sortedContacts[index].substring(0, 1)), // Display the first letter of the contact name
                        ),
                        title: Text(formatAddress(sortedContacts[index])),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                phrase: phrase,
                                ed25519Address: ed25519Address,
                                recipientAddress:sortedContacts[index] , // Assuming you want to pass the same ed25519Address for every contact
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300], // Placeholder background color for avatar
                      child: Text(sortedContacts[index].substring(0, 1)), // Display the first letter of the contact name
                    ),
                    title: Text(formatAddress(sortedContacts[index])),
                    onTap: () {
                      // Handle further actions, such as navigating to a chat screen
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GroupChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Chat',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(227, 224, 224, 0.5),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(child: Text('This is the group chat page')),
    );
  }
}