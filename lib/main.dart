import 'package:archery_toolkit/app.dart';
import 'package:archery_toolkit/db/db.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/find_locale.dart';
import 'package:provider/provider.dart';

void main() async {
  final db = AppDatabase.open();

  await findSystemLocale();
  await initializeDateFormatting();

  runApp(Provider.value(value: db, child: const App()));
}
