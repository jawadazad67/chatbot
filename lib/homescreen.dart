import 'dart:io';
import 'dart:typed_data';

import 'package:chatbot/userprofile/userprofilescreen.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:chatbot/theme_provider.dart';
import 'package:chatbot/logout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Gemini gemini = Gemini.instance; // Initialize Gemini instance

  List<ChatMessage> messages = []; // List to hold chat messages

  // Current user details
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");

  // Gemini user details
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
        "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Gemini chatBot"), // Title of the app bar
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkTheme
                  ? Icons.dark_mode
                  : Icons.light_mode, // Toggle theme icon
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(); // Toggle theme
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Start a New Chat'),
              onTap: () {
                _startNewChat(); // Start a new chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                logout(context); // Logout function
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserProfileScreen(), // Navigate to user profile screen
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildUI(), // Build the main UI
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(
            onPressed: _sendMediaMessage, // Send media message
            icon: const Icon(
              Icons.image,
            ),
          ),
        ],
        inputDecoration: InputDecoration(
          filled: true,
          fillColor: Provider.of<ThemeProvider>(context).isDarkTheme
              ? Colors.grey[800]
              : Colors.white,
          hintText: "Type your message...",
          hintStyle: TextStyle(
            color: Provider.of<ThemeProvider>(context).isDarkTheme
                ? Colors.white70
                : Colors.black54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
        ),
        inputTextStyle: TextStyle(
          color: Provider.of<ThemeProvider>(context).isDarkTheme
              ? Colors.white
              : Colors.black,
        ),
      ),
      currentUser: currentUser, // Current user
      onSend: _sendMessage, // Function to send message
      messages: messages, // List of messages
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages]; // Add new message to the list
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url)
              .readAsBytesSync(), // Read image bytes
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(
            () {
              messages = [lastMessage!, ...messages]; // Update last message
            },
          );
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response, // Create new message
          );
          setState(() {
            messages = [message, ...messages]; // Add new message to the list
          });
        }
      });
    } catch (e) {
      print(e); // Print any errors
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker(); // Initialize image picker
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );

    // Check if the user did not pick any image
    if (file == null) {
      // If no image is picked, navigate back to the home screen

      return;
    }

    // If an image is picked, send the media message
    ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: "Describe this picture?", // Message text for image
      medias: [
        ChatMedia(
          url: file.path,
          fileName: "",
          type: MediaType.image, // Media type is image
        )
      ],
    );
    _sendMessage(chatMessage); // Send media message
  }

  void _startNewChat() {
    Navigator.pop(context); // Close the drawer
    setState(() {
      messages = []; // Clear messages to start a new chat
    });
  }
}
