import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/utils/utils.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  State<Intro> createState() {
    return _IntroState();
  }
}

class _IntroState extends State<Intro> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// عند انتهاء عرض الشرح
  void _onCompleted() {
    AppBloc.applicationCubit.onCompletedIntro();
  }

  @override
  Widget build(BuildContext context) {
    /// قائمة صفحات العرض التقديمي
    final List<PageViewModel> pages = [
      PageViewModel(
        pageColor: Color.fromRGBO(0, 112, 60, 1), // الأخضر الرئيسي المستخدم في التصميم
        bubble: const Icon(
          Icons.shop,
          color: Colors.white,
        ),
        body: Text(
          "اكتشف المطاعم المفضلة وكل التفاصيل عنها.",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        title: Text(
          Translate.of(context).translate('التسوق'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white),
        ),
        mainImage: Image.asset(
          Images.intro1,
          fit: BoxFit.contain,
        ),
      ),
      PageViewModel(
        pageColor: Color.fromRGBO(0, 112, 60, 1), // استخدام نفس اللون الأخضر في جميع الصفحات
        bubble: const Icon(
          Icons.phonelink,
          color: Colors.white,
        ),
        body: Text(
          Translate.of(context).translate('كل المطاعم في مكان واحد.'),
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
        ),
        title: Text(
          Translate.of(context).translate('سهولة التصفح'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white),
        ),
        mainImage: Image.asset(
          Images.intro2,
          fit: BoxFit.contain,
        ),
      ),
      PageViewModel(
        pageColor: Color.fromRGBO(0, 112, 60, 1), // اللون الأخضر للتوحيد
        bubble: const Icon(
          Icons.home,
          color: Colors.white,
        ),
        body: Text(
          Translate.of(context).translate('قيّم تجربتك بكل سهولة.'),
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: Colors.white),
        ),
        title: Text(
          Translate.of(context).translate('التقييم'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white),
        ),
        mainImage: Image.asset(
          Images.intro3,
          fit: BoxFit.contain,
        ),
      ),
    ];

    /// بناء واجهة الصفحة
    return Scaffold(
      body: IntroViewsFlutter(
        pages,
        onTapSkipButton: _onCompleted,
        onTapDoneButton: _onCompleted,
        doneText: Text(Translate.of(context).translate('تم')),
        nextText: Text(Translate.of(context).translate('التالي')),
        skipText: Text(Translate.of(context).translate('تخطي')),
        backText: Text(Translate.of(context).translate('عودة')),
        pageButtonTextStyles: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
