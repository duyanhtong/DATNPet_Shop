import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/feedback.model.dart';
import 'package:shop_app/services/api.dart';

class ListProductReviewScreen extends StatefulWidget {
  final int productId;

  const ListProductReviewScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ListProductReviewScreen> createState() =>
      _ListProductReviewScreenState();
}

class _ListProductReviewScreenState extends State<ListProductReviewScreen> {
  late Future<List<FeedbackModel>> _feedbacksFuture;
  List<FeedbackModel> _feedbacks = [];
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _feedbacksFuture = _getListFeedback();
    _scrollController.addListener(_onScroll);
  }

  Future<List<FeedbackModel>> _getListFeedback() async {
    try {
      final feedbacks = await Api.getListFeedbackPublic(
        status: 'reviewed',
        product_id: widget.productId,
        page: _currentPage,
      );
      if (feedbacks.isNotEmpty) {
        setState(() {
          _currentPage++;
          _feedbacks.addAll(feedbacks);
        });
      }
      _isLoading = false;
      return _feedbacks;
    } catch (error) {
      print('Error fetching feedbacks: $error');
      throw error;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        _getListFeedback();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget buildFeedbackCard(FeedbackModel feedback) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            if (feedback.rating != null)
              Row(
                children: List.generate(
                  feedback.rating!.round(),
                  (index) => const Icon(Icons.star, color: kPrimaryColor),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedback.image != null)
              Image.network(
                feedback.image!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            if (feedback.comment != null) Text(feedback.comment!),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedbackModel>>(
      future: _feedbacksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && _feedbacks.isEmpty) {
          return const Center(
            child: Text('Sản phẩm chưa có đánh giá'),
          );
        } else {
          return ListView.builder(
            controller: _scrollController,
            itemCount: _feedbacks.length + 1,
            itemBuilder: (context, index) {
              if (index == _feedbacks.length) {
                return _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink();
              }
              final feedback = _feedbacks[index];
              return buildFeedbackCard(feedback);
            },
          );
        }
      },
    );
  }
}
