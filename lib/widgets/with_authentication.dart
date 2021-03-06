import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raashan/data/user_repository.dart';
import 'package:raashan/models/user_info.dart';
import 'package:raashan/screens/login_page.dart';
import 'package:raashan/services/navigation.service.dart';
import 'package:raashan/utils/utils.dart';
import 'package:raashan/widgets/request_user_info_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WithAuthentication extends StatelessWidget {
  final Widget child;
  final bool skippableUserInfo;
  final bool redirect;
  WithAuthentication({
    @required this.child,
    this.skippableUserInfo = false,
    this.redirect = false,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer<UserRepository>(builder: (context, UserRepository user, _) {
      if (user.status == Status.Unauthenticated) {
        if (redirect)
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    child: SvgPicture.asset('assets/images/login.svg'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'You need to login to proceed.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationService.of(context).pushPage(LoginPage());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: getPrimaryColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        else
          return LoginPage(redirect: redirect);
      } else
        switch (user.status) {
          case Status.Authenticating:
          case Status.Unauthenticated:
            return LoginPage(redirect: redirect);
          case Status.Authenticated:
            if (user.loadingUserInfo)
              return LoadingScreen();
            else if (!skippableUserInfo) {
              UKUserInfo userInfo = user.userInfo;
              if (userInfo.name == null ||
                  userInfo.name.length == 0 ||
                  userInfo.mobile == null ||
                  userInfo.mobile.length == 0) {
                return RequestUserInfoPage(
                  userInfo: userInfo,
                );
              } else {
                return child;
              }
            } else {
              return child;
            }
            break;
          case Status.Uninitialized:
            return LoadingScreen();
          default:
            return LoginPage();
        }
    });
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: RaisedButton(
                color: getPrimaryColor(),
                onPressed: () {
                  Provider.of<UserRepository>(context).signOut();
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
