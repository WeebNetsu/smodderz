import 'package:flutter/material.dart';
import 'package:smodderz/constants/app_routes.dart';
import 'package:smodderz/constants/constants.dart';
import 'package:smodderz/views/views.dart';

Map<String, Widget Function(BuildContext)> routes = {AppRoutes.mods: (context) => const ModsView()};
