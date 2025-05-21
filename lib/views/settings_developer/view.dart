import 'package:flutter/material.dart';
import 'package:smodderz/models/models.dart';
import 'package:smodderz/widgets/widgets.dart';

class SettingsDeveloperView extends StatefulWidget {
  const SettingsDeveloperView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(builder: (context) => const SettingsDeveloperView());

  @override
  State<SettingsDeveloperView> createState() => _SettingsDeveloperViewState();
}

class _SettingsDeveloperViewState extends State<SettingsDeveloperView> {
  final _userPreferences = UserPreferencesModel();

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _userPreferences.loadDataFromFile().then(
      (value) => {
        setState(() {
          _loading = false;
        }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TopNavigationWidget(title: "Developer"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Developer Mode"),
                  Checkbox(
                    value: _userPreferences.developerMode,
                    onChanged: (bool? value) async {
                      if (value != null) _userPreferences.developerMode = value;
                      await _userPreferences.saveToFileData();
                      await _userPreferences.loadDataFromFile();
                      //   to update widgets
                      setState(() {});
                    },
                  ),
                ],
              ),
              Text(
                "This will apply extra logging for development purposes",
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}
