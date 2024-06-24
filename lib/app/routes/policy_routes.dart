import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/modules/policies/policy_page.dart';

class PolicyRoutes {
  PolicyRoutes._();

  static final routes = [
    GetPage(
      name: Constants.routePolicyPage,
      page: () => const PolicyPage(),
      // binding: WelcomeBinding(),
    ),
  ];
}
