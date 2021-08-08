import 'dart:convert';

import 'package:Drinkr/utils/difficulty.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

import 'file.dart';
import '../menus/name_select.dart';
import 'player.dart';
import '../menus/setting.dart';
import 'types.dart';

const String SAVED_CUSTOM_SETTING = "SAVED_CUSTOM_SETTING";
