import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}

/// Get date as a string for display.
String getFormattedDate(String date) {
  /// Convert into local date format.
  var localDate = DateTime.parse(date).toLocal();

  /// inputFormat - format getting from api or other func.
  /// e.g If 2021-05-27 9:34:12.781341 then format should be yyyy-MM-dd HH:mm
  /// If 27/05/2021 9:34:12.781341 then format should be dd/MM/yyyy HH:mm
  var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
  var inputDate = inputFormat.parse(localDate.toString());

  /// outputFormat - convert into format you want to show.
  var outputFormat = DateFormat('dd/MM/yyyy HH:mm');
  var outputDate = outputFormat.format(inputDate);

  return outputDate.toString();
}

extension E on String {
  String lastChars(int n) => substring(length - n);
}
