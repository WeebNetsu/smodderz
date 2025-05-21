import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smodderz/constants/constants.dart';
import 'package:smodderz/utils/utils.dart';
import 'package:smodderz/widgets/widgets.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(builder: (context) => const SettingsView());

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PackageInfo? _packageInfo;

  Future<void> _loadData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TopNavigationWidget(
                  title: "Settings",
                  rightContent: _packageInfo != null ? Text("v${_packageInfo?.version ?? "v???"}") : null,
                ),

                ArrowRowButton(
                  text: "Developer",
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsDeveloper),
                ),
                ArrowRowButton(text: "Donate", onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsDonate)),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await openUrl('https://github.com/WeebNetsu');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Developed by '),
                      Text('WeebNetsu', style: TextStyle(decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
