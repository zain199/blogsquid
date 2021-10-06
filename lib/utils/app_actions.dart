import 'package:blogsquid/config/app.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppAction {
  logout(account, token) async {
    print(token);
    if (account.state['login_type'] == 'social') {
      try {
        if (account.state['login_mode'] == 'google') {
          GoogleSignIn _googleSignIn = GoogleSignIn();
          await _googleSignIn.signOut();
        } else if (account.state['login_mode'] == 'facebook') {
          await FacebookAuth.instance.logOut();
        }

        account.state = {};
        token.state = "";
        var box = await Hive.openBox('appBox');
        box.delete('account');
        box.delete('token');
      } catch (e) {
        print(e);
      }
    } else {
      account.state = {};
      token.state = "";
      var box = await Hive.openBox('appBox');
      box.delete('account');
      box.delete('token');
    }
  }

  newToastSuccess(context, String message) {
    showToastWidget(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        margin: EdgeInsets.symmetric(horizontal: 25.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Color(0xFF0E7E19),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconsPath + 'emoji-happy.svg',
              height: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '$message',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () => {ToastManager().dismissAll(showAnim: true)},
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Color(0xFF0C5814),
                    borderRadius: BorderRadius.circular(20)),
                child: SvgPicture.asset(
                  iconsPath + 'close.svg',
                ),
              ),
            ),
          ],
        ),
      ),
      context: context,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: Offset(0.0, -3.0),
      reverseEndOffset: Offset(0.0, -3.0),
      duration: Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  newToastError(context, String message) {
    showToastWidget(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        margin: EdgeInsets.symmetric(horizontal: 25.0),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          color: Color(0xFF9F2828),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconsPath + 'emoji-sad.svg',
              height: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '$message',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () => {ToastManager().dismissAll(showAnim: true)},
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Color(0xFF842121),
                    borderRadius: BorderRadius.circular(20)),
                child: SvgPicture.asset(
                  iconsPath + 'close.svg',
                ),
              ),
            ),
          ],
        ),
      ),
      context: context,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: Offset(0.0, -3.0),
      reverseEndOffset: Offset(0.0, -3.0),
      duration: Duration(seconds: 4),
      //Animation duration   animDuration * 2 <= duration
      animDuration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  bool validateEmails(email) {
    if (EmailValidator.validate(email)) {
      return true;
    } else {
      return false;
    }
  }
}
