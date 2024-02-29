import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:salt_strong_poc/auth/registration/registration_controller.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layer_modifier.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layers_widgets/custom_list_tile.dart';
import 'package:salt_strong_poc/routing/router.dart';

import '../../../../../../auth/registration/email_provider.dart';
import '../../../../../../auth/widgets/salt_strong_web_view.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../constants/colors.dart';
import '../../../../../models/user/user.dart';
import '../../../../../modelsV2/user/delete_account_request.dart';
import '../../../../../services/in_app_purchase/in_app_purchase_service.dart';
import '../../../../../services/user/user_service.dart';
import '../../../controller/customized_providers.dart';
import '../../are_you_sure_delete_popup.dart';
import '../../salt_strong_snackbar.dart';
import '../../user_needs_cancel_subsription_popup.dart';

enum SmartTidesFilter {
  tides,
  weather,
  feedingTimes,
  wind;

  String get name {
    switch (this) {
      case SmartTidesFilter.tides:
        return 'Tides';
      case SmartTidesFilter.weather:
        return 'Weather';
      case SmartTidesFilter.feedingTimes:
        return 'Feeding Times';
      case SmartTidesFilter.wind:
        return 'Wind';
    }
  }
}

class FilterState {
  final List<SmartTidesFilter> selectedFilters;

  // final bool shouldReturnToSmartTidesGraph;

  const FilterState({
    required this.selectedFilters,
    // required this.shouldReturnToSmartTidesGraph,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is FilterState && runtimeType == other.runtimeType;

  @override
  int get hashCode => selectedFilters.hashCode;

  FilterState copyWith({
    List<SmartTidesFilter>? selectedFilters,
    // bool? shouldReturnToSmartTidesGraph,
  }) {
    return FilterState(
      selectedFilters: selectedFilters ?? this.selectedFilters,
      // shouldReturnToSmartTidesGraph: shouldReturnToSmartTidesGraph ?? this.shouldReturnToSmartTidesGraph,
    );
  }
}

final filterNotifierProvider = NotifierProvider.autoDispose<FilterNotifier, FilterState>(
  () => FilterNotifier(),
);

class FilterNotifier extends AutoDisposeNotifier<FilterState> {
  @override
  FilterState build() {
    ref.keepAlive();

    return const FilterState(
      selectedFilters: [...SmartTidesFilter.values],
      // shouldReturnToSmartTidesGraph: false,
    );
  }

  void setSelectedFilters(SmartTidesFilter filter, BuildContext context) {
    bool filterAdded = false;
    final selectedFilters = state.selectedFilters.toList();
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
      filterAdded = true;
    }

    state = state.copyWith(selectedFilters: selectedFilters);
    debugCheckHasScaffoldMessenger(context);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(15.w, 5.h, 15.w, 20.h),
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: SaltStrongSnackbar(
            snackbarMessageVariable: filter.name,
            snackbarMessageFixed: filterAdded ? ' added to Smart Tides.' : ' removed from Smart Tides.',
            isForCalendar: false,
          )),
    ));
  }
}

Future<void> openUrl(context, String url) async {
  final controller = await SaltStrongWebView.init(url);
  // ignore: use_build_context_synchronously
  await SaltStrongWebView.open(controller, context);
}

const textButtonStyle = TextStyle(fontWeight: FontWeight.w600);

class FilterWidget extends ConsumerStatefulWidget {
  const FilterWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends ConsumerState<FilterWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilters = ref.watch(selectedFilterProvider);
    bool isTidesSelected = selectedFilters.contains(SmartTidesFilter.tides);
    bool isWeatherSelected = selectedFilters.contains(SmartTidesFilter.weather);
    bool isFeedingTimesSelected = selectedFilters.contains(SmartTidesFilter.feedingTimes);
    bool isWindSelected = selectedFilters.contains(SmartTidesFilter.wind);
    final double height = 346;
    return Container(
      decoration: BoxDecoration(
        gradient: SaltStrongColors.smartTideFilterGradient,
      ),
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  ref.read(smartTidesTabBarViewIndex.notifier).state = 0;
                },
                child: const Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          'Smart Tide Filters',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // const SizedBox(
          //   height: 32,
          // ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomListTile(
                  title: 'Tides',
                  isSelected: isTidesSelected,
                  icon: Assets.icons.tideWave.svg(),
                  onSelected: (bool value) {
                    ref.read(filterNotifierProvider.notifier).setSelectedFilters(SmartTidesFilter.tides, context);
                  },
                  checkmark: isTidesSelected ? const Icon(Icons.check, color: SaltStrongColors.checkmark) : null,
                  paddingLeft: 12,
                ),
                SizedBox(
                  height: 14.h,
                ),
                CustomListTile(
                  title: 'Weather',
                  isSelected: isWeatherSelected,
                  icon: Assets.icons.weather.svg(),
                  checkmark: isWeatherSelected ? const Icon(Icons.check, color: SaltStrongColors.checkmark) : null,
                  onSelected: (bool value) {
                    ref.read(filterNotifierProvider.notifier).setSelectedFilters(SmartTidesFilter.weather, context);
                  },
                  paddingLeft: 12,
                ),
                SizedBox(
                  height: 14.h,
                ),
                CustomListTile(
                  title: 'Feeding Times',
                  isSelected: isFeedingTimesSelected,
                  icon: Assets.icons.feedTime.svg(),
                  checkmark: isFeedingTimesSelected ? const Icon(Icons.check, color: SaltStrongColors.checkmark) : null,
                  onSelected: (bool value) {
                    ref
                        .read(filterNotifierProvider.notifier)
                        .setSelectedFilters(SmartTidesFilter.feedingTimes, context);
                  },
                  paddingLeft: 12,
                ),
                SizedBox(
                  height: 14.h,
                ),
                CustomListTile(
                  title: 'Wind',
                  isSelected: isWindSelected,
                  icon: Assets.icons.wind.svg(),
                  checkmark: isWindSelected ? const Icon(Icons.check, color: SaltStrongColors.checkmark) : null,
                  onSelected: (bool value) {
                    ref.read(filterNotifierProvider.notifier).setSelectedFilters(SmartTidesFilter.wind, context);
                  },
                  paddingLeft: 12,
                ),
              ],
            ),
          ),

          /// Privacy Policy, Terms of use and Logout feature
          Container(height: 1, width: double.infinity, color: Colors.black),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => openUrl(context, Links.privacyPolicy),
                  child: const Text('Privacy Policy', style: textButtonStyle),
                ),
                TextButton(
                  onPressed: () => openUrl(context, Links.termsOfUse),
                  child: const Text('Terms of Use', style: textButtonStyle),
                ),
                TextButton(
                  onPressed: () async {
                    showLoadingDialog(context);
                    await ref.read(userServiceProvider).logout();
                    ref.read(smartTidesTabBarViewIndex.notifier).state = 0;
                    await GoRouter.of(context).pushReplacement(RoutePaths.signIn);
                  },
                  child: Text(
                    'Logout',
                    style: textButtonStyle.copyWith(
                      color: SaltStrongColors.btnRed,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    deleteAccount(context);
                  },
                  child: Text(
                    'Delete Account',
                    style: textButtonStyle.copyWith(
                      color: SaltStrongColors.btnRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void deleteAccount(BuildContext context) async {
    AreYouSureDeletePopUp(
      onDeletePressed: () async {
        await deleteAccountOnConfirmation(context);
      },
    ).show(context);
  }

  Future<void> deleteAccountOnConfirmation(BuildContext context) async {
    logger.info('----------deleting account------------');
    // get email
    final email = ref.read(emailProvider);
    logger.info('email for delete: $email');
    // get accessKey2
    final registrationProvider = ref.read(registrationControllerProvider.notifier);
    final userAccessData = await registrationProvider.fetchUserAccessData();
    logger.info('accesK2: ${userAccessData.accessKey2!}');
    // get rev_sub_id
    final customer = await InAppPurchaseService.getCustomerInfo();
    final revSubId = customer.originalAppUserId;
    logger.info('revSubId for delete: $revSubId');

    final request = DeleteAccountRequest(email: email, accessKey: userAccessData.accessKey2!, revSubId: revSubId);
    final deleteAccountResponse = await ref.read(userServiceProvider).deleteAccount(request);
    if (deleteAccountResponse.status == 'success') {
      ref.read(smartTidesTabBarViewIndex.notifier).state = 0;
      await GoRouter.of(context).pushReplacement(RoutePaths.welcomeBack);
    }
  }
}
