import 'package:flutter/material.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/feedback.model.dart';
import 'package:shop_app/models/order.model.dart';
import 'package:shop_app/screens/init_screen.dart';
import 'package:shop_app/screens/order/components/order_card.component.dart';
import 'package:shop_app/services/api.dart';

class OrdersTab extends StatefulWidget {
  final String status;
  final bool isButton;
  final bool isAdmin;
  final String nameTab;

  const OrdersTab({
    Key? key,
    required this.status,
    this.isButton = true,
    this.isAdmin = false,
    required this.nameTab,
  }) : super(key: key);

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<OrderModel> orders = [];
  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  List<FeedbackModel> feedbacks = [];
  bool isReview = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_scrollListener);
    if (!widget.isAdmin && widget.nameTab == OrderStatusEnum.Delivered) {
      getListFeedback(status: "pending");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForScreenChanges();
    });
  }

  void _listenForScreenChanges() {
    ModalRoute.of(context)!.addScopedWillPopCallback(() async {
      await _refreshOrders();
      return true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _refreshOrders();
  }

  @override
  void didUpdateWidget(covariant OrdersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status ||
        oldWidget.isAdmin != widget.isAdmin ||
        oldWidget.nameTab != widget.nameTab) {
      _refreshOrders();
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      orders.clear();
      _currentPage = 1;
    });
    await _loadOrders();
  }

  Future<void> _loadOrders({bool isFetchingMore = false}) async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        if (isFetchingMore) {
          _isFetchingMore = true;
        } else {
          _isLoading = true;
        }
      });
    }

    try {
      final List<OrderModel> newOrders =
          await Api.getOrderByStatus(status: widget.status, page: _currentPage);
      if (mounted) {
        setState(() {
          orders.addAll(newOrders);
          _currentPage++;
        });
      }
    } catch (error) {
      debugPrint('Failed to load more orders: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isFetchingMore) {
      _currentPage++;
      _loadOrders(isFetchingMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = (widget.status == OrderStatusEnum.PendingConfirmation &&
            widget.isAdmin) ||
        (widget.status == OrderStatusEnum.WaitingForDelivery &&
            widget.isAdmin) ||
        (widget.status == OrderStatusEnum.Delivered && widget.isAdmin);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: kPrimaryColor,
        ),
      );
    }

    if (orders.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Danh sách đang trống'),
          const SizedBox(height: 20),
          if (widget.isButton)
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    InitScreen.routeName,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Tiếp tục mua sắm',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                ),
              ),
            ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: orders.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == orders.length && _isFetchingMore) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (!widget.isAdmin &&
            widget.nameTab == OrderStatusEnum.Delivered &&
            orders[index].status == OrderStatusEnum.Delivered) {
          for (final feedback in feedbacks) {
            if (feedback.orderId == orders[index].id) {
              isReview = false;
            }
          }
        }

        return OrderCard(
            order: orders[index],
            isAdmin: isAdmin,
            nameTab: widget.nameTab,
            isReview: isReview,
            onOrderConfirmed: _refreshOrders);
      },
    );
  }

  Future<void> getListFeedback({String? status}) async {
    try {
      final res = await Api.getListFeedback(status: status);
      if (mounted) {
        setState(() {
          feedbacks = res;
        });
      }
    } catch (error) {
      print(error.toString());
    }
  }
}
