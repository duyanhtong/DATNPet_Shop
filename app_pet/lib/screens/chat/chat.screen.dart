import 'package:flutter/material.dart';
import 'package:ikchatbot/ikchatbot.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/chat/keyword_response.chat.dart';

class ChatScreen extends StatefulWidget {
  //final IkChatBotConfig  chatBotConfig;

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final bool _chatIsOpened = false;
  @override
  Widget build(BuildContext context) {
    final chatBotConfig = IkChatBotConfig(
      //SMTP Rating to your mail Settings
      ratingIconYes: const Icon(Icons.star),
      ratingIconNo: const Icon(Icons.star_border),
      ratingIconColor: Colors.black,
      ratingBackgroundColor: Colors.white,
      ratingButtonText: 'Đánh giá đoạn chat',
      thankyouText: 'Cảm ơn vì đánh giá của bạn!',
      ratingText: 'Đánh giá trải nghiệm của bạn:',
      ratingTitle: 'Cảm ơn bạn đã sử dụng chức năng của chúng tôi!',
      body: 'email',
      subject: 'Đánh giá',
      recipient: 'recipient@example.com',
      isSecure: false,
      senderName: 'Your Name',
      smtpUsername: 'Your Email',
      smtpPassword: 'your password',
      smtpServer: 'stmp.gmail.com',
      smtpPort: 587,
      //Settings to your system Configurations
      sendIcon: const Icon(Icons.send, color: Colors.red),
      userIcon: const Icon(Icons.person_2_rounded, color: Colors.white),
      botIcon: const Icon(Icons.android, color: Colors.white),
      botChatColor: const Color.fromARGB(255, 104, 0, 101),
      delayBot: 100,
      closingTime: 1,
      delayResponse: 1,
      userChatColor: const Color.fromARGB(255, 103, 0, 0),
      waitingTime: 1,
      keywords: keywords,
      responses: responses,
      backgroundColor: Colors.white,
      backgroundImage:
          'https://i.pinimg.com/736x/d2/bf/d3/d2bfd3ea45910c01255ae022181148c4.jpg',
      backgroundAssetimage: "assets/images/bg.jpg",
      initialGreeting:
          "Xin chào \nChào mừng bạn đến với cửa hàng Mưa Pet\nCửa hàng rất hân hạnh được phục vụ bạn!",

      defaultResponse: "Xin lỗi, tôi không hiểu câu trả lời của bạn.",
      inactivityMessage: "Bạn còn cần trợ giúp gì nữa không?",
      closingMessage: "Cuộc trò chuyện này bây giờ sẽ kết thúc.",
      inputHint: 'Nhập tin nhắn',
      waitingText: 'Vui lòng chờ...',
      useAsset: false,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trò chuyện tự động',
            style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ),
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   if(_chatIsOpened =  false) {
        //     setState(() {
        //     _chatIsOpened = true;
        //     });
        //   }else {
        //     setState(() {
        //       _chatIsOpened = false;
        //     });
        //   }
        //
        // },
        // child: Icon(Icons.chat),),
        body: _chatIsOpened
            ? const Center(
                child: Text('Chào mừng đến với cửa hàng Mưa Pet'),
              )
            : ikchatbot(config: chatBotConfig));
  }
}
