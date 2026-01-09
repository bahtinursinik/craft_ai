import 'package:flutter/material.dart';

class AppDimens {
  AppDimens._();

  // PADDING & MARGIN
  static const double p4 = 4;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p24 = 24;
  static const double p32 = 32;
  static const double p40 = 40;
  static const double p48 = 48;
  static const double p56 = 56;

  // RADIUS
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r32 = 32;
  static const double rCircle = 100;

  // ICON SIZES
  static const double iconSmall = 16;
  static const double iconMedium = 24;
  static const double iconLarge = 32;
  static const double iconXLarge = 48;

  // EDGE INSETS
  static const EdgeInsets all4 = EdgeInsets.all(p4);
  static const EdgeInsets all8 = EdgeInsets.all(p8);
  static const EdgeInsets all12 = EdgeInsets.all(p12);
  static const EdgeInsets all16 = EdgeInsets.all(p16);
  static const EdgeInsets all24 = EdgeInsets.all(p24);
  static const EdgeInsets all32 = EdgeInsets.all(p32);

  static const EdgeInsets horz16 = EdgeInsets.symmetric(horizontal: p16);
  static const EdgeInsets vert16 = EdgeInsets.symmetric(vertical: p16);

  static const double buttonHeight = 56;
  static const double borderWidth = 1.5;
  static const double blurRadius = 15;
  static const double inputBorderWidth = 1.5;

  static const Offset cardShadowOffset = Offset(0, 5);
  // Dikey Boşluklar (Height)
  static const Widget gapH4 = SizedBox(height: p4);
  static const Widget gapH8 = SizedBox(height: p8);
  static const Widget gapH12 = SizedBox(height: p12);
  static const Widget gapH16 = SizedBox(height: p16);
  static const Widget gapH20 = SizedBox(height: p20);
  static const Widget gapH24 = SizedBox(height: p24);
  static const Widget gapH32 = SizedBox(height: p32);

  // Yatay Boşluklar (Width)
  static const Widget gapW4 = SizedBox(width: p4);
  static const Widget gapW8 = SizedBox(width: p8);
  static const Widget gapW12 = SizedBox(width: p12);
  static const Widget gapW16 = SizedBox(width: p16);
  static const Widget gapW20 = SizedBox(width: p20);
  static const Widget gapW24 = SizedBox(width: p24);
}
