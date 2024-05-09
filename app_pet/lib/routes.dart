import 'package:flutter/widgets.dart';
import 'package:shop_app/screens/admin-dashboard/dashboard_screen.dart';
import 'package:shop_app/screens/admin_order/admin_order.screen.dart';
import 'package:shop_app/screens/checkout/paypal.screen.dart';
import 'package:shop_app/screens/order/order.screen.dart';
import 'package:shop_app/screens/order_detail/order_detail.screen.dart';
import 'package:shop_app/screens/preview_order/order_preview.screen.dart';
import 'package:shop_app/screens/product_admin/components/add_product.screen.dart';
import 'package:shop_app/screens/product_admin/product_admin.screen.dart';

import 'package:shop_app/screens/products/products_screen.dart';

import 'screens/cart/cart_screen.dart';
import 'screens/complete_profile/complete_profile_screen.dart';
import 'screens/details/details_screen.dart';
import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/init_screen.dart';
import 'screens/login_success/login_success_screen.dart';
import 'screens/otp/otp_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash/splash_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  OtpScreen.routeName: (context) => const OtpScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  ProductsScreen.routeName: (context) => const ProductsScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  CheckoutPayPalPage.routeName: (context) => const CheckoutPayPalPage(),
  OrdersScreen.routeName: (context) => OrdersScreen(),
  AdminOrdersScreen.routeName: (context) => AdminOrdersScreen(),
  ProductManagementScreen.routeName: (context) => ProductManagementScreen(),
  OrderPreviewScreen.routeName: (context) => OrderPreviewScreen(),
  AddProductScreen.routeName: (context) => AddProductScreen(),
};
