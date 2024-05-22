import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/components/custom_dialog.dart';
import 'package:shop_app/models/user.model.dart';
import 'package:shop_app/services/api.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  late Future<UserModel?> futureProfilePic;
  File? selectedImage;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    futureProfilePic = getProfilePic();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<UserModel?> getProfilePic() async {
    try {
      var profile = await Api.getProfile();

      if (profile != null && !_disposed) {
        return profile;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final result = await picker.pickImage(source: source);
      if (result != null && !_disposed) {
        setState(() {
          selectedImage = File(result.path);
        });
        showPreviewDialog(context);
      }
    } catch (e) {
      // Handle camera access denied error
      if (e is PlatformException && e.code == 'camera_access_denied') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Truy cập bị từ chối'),
              content: const Text('Vui lòng cấp quyền truy cập vào máy ảnh.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle other exceptions
        print('Error: $e');
      }
    }
  }

  void showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận ảnh đại diện'),
          content: SizedBox(
            height: 200,
            child: selectedImage != null
                ? Image.file(selectedImage!)
                : const Text('Chưa chọn ảnh'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy bỏ'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final userId = await _getUserIdFromFuture();

                if (userId != null && !_disposed) {
                  String? uploadResult =
                      await Api.uploadImage(userId, selectedImage!);
                  if (uploadResult == "OK" && !_disposed) {
                    setState(() {
                      futureProfilePic = getProfilePic();
                    });
                  } else {
                    showCustomDialog(
                        context, "Cập nhật ảnh", "Cập nhật ảnh lỗi");
                  }
                } else if (!_disposed) {
                  showCustomDialog(
                      context, "Cập nhật ảnh", "Bạn cần đăng nhập tài khoản!");
                  print('Error: User ID not available for upload');
                }
              },
              child: const Text('Tải lên'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _getUserIdFromFuture() async {
    // Extract user ID from futureProfilePic (assuming it contains a UserModel)
    final user = await futureProfilePic;

    if (user != null) {
      return user.id; // Return user ID
    } else {
      return null; // Handle case where user data is unavailable
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: futureProfilePic,
      builder: (context, snapshot) {
        Widget profileImage;
        if (snapshot.connectionState == ConnectionState.waiting) {
          profileImage = const CircleAvatar(
            backgroundImage: AssetImage("assets/images/2.png"),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          profileImage = const CircleAvatar(
            backgroundImage: AssetImage("assets/images/2.png"),
          );
        } else {
          final user = snapshot.data!;
          profileImage = CircleAvatar(
            backgroundImage: NetworkImage(user.image!),
          );
        }

        return SizedBox(
          height: 115,
          width: 115,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              profileImage,
              Positioned(
                right: -16,
                bottom: 0,
                child: SizedBox(
                  height: 46,
                  width: 46,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFF5F6F9),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Chụp ảnh'),
                                onTap: () => pickImage(ImageSource.camera),
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Chọn ảnh từ thư viện'),
                                onTap: () => pickImage(ImageSource.gallery),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: SvgPicture.asset("assets/icons/Camera Icon.svg"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
