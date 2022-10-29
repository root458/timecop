import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timecop/blocs/locale/locale_bloc.dart';
import 'package:timecop/blocs/notifications/notifications_bloc.dart';
import 'package:timecop/blocs/projects/projects_bloc.dart';
import 'package:timecop/blocs/settings/bloc.dart';
import 'package:timecop/blocs/theme/theme_bloc.dart';
import 'package:timecop/blocs/timers/timers_bloc.dart';
import 'package:timecop/blocs/timers/timers_event.dart';
import 'package:timecop/data_providers/data/data_provider.dart';
import 'package:timecop/data_providers/data/mock_data_provider.dart';
import 'package:timecop/data_providers/notifications/notifications_provider.dart';
import 'package:timecop/data_providers/settings/mock_settings_provider.dart';
import 'package:timecop/data_providers/settings/settings_provider.dart';
import 'package:timecop/main.dart' as app;
import 'package:timecop/models/timer_entry.dart';
import 'package:timecop/screens/dashboard/components/DescriptionField.dart';
import 'package:timecop/screens/dashboard/components/RunningTimerRow.dart';
import 'package:timecop/screens/dashboard/components/StartTimerButton.dart';
import 'package:timecop/screens/dashboard/components/StoppedTimerRow.dart';

bool didConvertedFlutterToSurfaceImage = false;

Future<void> takeScreenshot(WidgetTester tester, IntegrationTestWidgetsFlutterBinding binding, String name) async {
  if (kIsWeb) {
    await binding.takeScreenshot(name);
  } else if (Platform.isAndroid) {
    if (!didConvertedFlutterToSurfaceImage) {
      await binding.convertFlutterSurfaceToImage();
      didConvertedFlutterToSurfaceImage = true;
    }
    await tester.pumpAndSettle();
  }
  await binding.takeScreenshot(name);
}

void main() {

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('end-to-end test', () {

    testWidgets(
        'tap on the floating action button, verify counter',
        (tester) async {
          WidgetsFlutterBinding.ensureInitialized();
          final SettingsProvider settings = MockSettingsProvider();
          final DataProvider data = MockDataProvider(const Locale.fromSubtags(languageCode: "en"));
          NotificationsProvider notificationsProvider = await NotificationsProvider.load();
     // app.main();
      //await Future<void>.delayed(const Duration(seconds: 2));
        await tester.pumpWidget(MultiBlocProvider(
            providers: [
              BlocProvider<ThemeBloc>(
                create: (_) => ThemeBloc(settings),
              ),
              BlocProvider<LocaleBloc>(
                create: (_) => LocaleBloc(settings),
              ),
              BlocProvider<SettingsBloc>(
                create: (_) => SettingsBloc(settings, data),
              ),
              BlocProvider<TimersBloc>(
                create: (_) => TimersBloc(data, settings),
              ),
              BlocProvider<ProjectsBloc>(
                create: (_) => ProjectsBloc(data),
              ),
              BlocProvider<NotificationsBloc>(
                create: (_) => NotificationsBloc(notificationsProvider),
              ),
            ],
            child: app.TimeCopApp(settings: settings)
          )
        );

        await tester.pumpAndSettle();

        // start by switching to the dark theme
        Finder menuButton = find.byKey(const ValueKey("menuButton"));
        await tester.tap(menuButton);

        await tester.pumpAndSettle();

        Finder menuSettings = find.byKey(const ValueKey("menuSettings"));
        await tester.tap(menuSettings);

        await tester.pumpAndSettle();

        Finder themeOption = find.byKey(const ValueKey("themeOption"));
        await tester.tap(themeOption);

        await tester.pumpAndSettle();

        Finder themeDark = find.byKey(const ValueKey("themeDark"));
        await tester.tap(themeDark);

        await tester.pumpAndSettle();

        await takeScreenshot(tester, binding, "06 settings");

        await tester.pumpAndSettle();

        Finder backButton = find.byType(BackButton);
        await tester.tap(backButton);

        await tester.pumpAndSettle();

        await takeScreenshot(tester, binding, "01 dashboard");

        await tester.pumpAndSettle();

        Widget runningTimer = tester.firstWidget(find.byType(RunningTimerRow));
        Finder timer = find.byWidget(runningTimer);
        await tester.tap(timer);

        await tester.pumpAndSettle();

        Finder saveDetails = find.byKey(const ValueKey("saveDetails"));
        await tester.tap(saveDetails);

        await tester.pumpAndSettle();

        await takeScreenshot(tester, binding, "02 editor");

        await tester.pumpAndSettle();

        // Finder closeButton = find.byType(CloseButton);
        // await tester.tap(closeButton);

        // await tester.pumpAndSettle();
        //
        // menuButton = find.byKey(const ValueKey("menuButton"));
        //
        // await tester.tap(menuButton);
        //
        // await tester.pumpAndSettle();
        //
        // Finder menuProjects = find.byKey(const ValueKey("menuProjects"));
        // await tester.tap(menuProjects);
        //
        // await tester.pumpAndSettle();
        //
        // Finder addProject = find.byKey(const ValueKey("addProject"));
        // await tester.tap(addProject);
        //
        // await tester.pumpAndSettle();
        //
        // await tester.enterText(find.byType(TextFormField), "Test Project");
        // await tester.pumpAndSettle();
        //
        // Finder createButton = find.text("Create");
        // await tester.tap(createButton);
        //
        // await tester.pumpAndSettle();
        //
        //  await takeScreenshot(tester, binding, "03 projects");
        //
        //  await tester.pumpAndSettle();
        //
        // // then reports pages
        // await tester.tap(backButton);
        //
        // await tester.pumpAndSettle();
        //
        // menuButton = find.byKey(const ValueKey("menuButton"));
        //
        // await tester.tap(menuButton);
        //
        // await tester.pumpAndSettle();
        //
        // Finder menuReports = find.byKey(const ValueKey("menuReports"));
        // await tester.tap(menuReports);
        //
        // await tester.pumpAndSettle();
        //
        // await takeScreenshot(tester, binding, "04a projectBreakdown");
        //
        // await tester.pumpAndSettle();

    });
  });
}
