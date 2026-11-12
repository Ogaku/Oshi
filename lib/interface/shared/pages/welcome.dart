// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:event/event.dart';
import 'package:material_ui/material_ui.dart';
import 'package:oshi/extensions/runtime/standalone_calendar_provider.dart';
import 'package:oshi/interface/components/cupertino/sessions.dart' as cupertino;
import 'package:oshi/interface/components/material/sessions.dart' as material;
import 'package:oshi/interface/components/shim/page_routes.dart';
import 'package:oshi/interface/shared/containers.dart';
import 'package:oshi/interface/shared/session_management.dart';
import 'package:oshi/share/share.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, this.asApp = false});

  final bool asApp;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isCreatingCalendar = false;

  void _onGetStarted(BuildContext context) {
    final nav = Navigator.maybeOf(context);
    if (nav != null) {
      nav.push(
        AdaptivePageRoute(
          builder: (context) => Share.settings.appSettings.useCupertino
              ? cupertino.NewSessionPage(asApp: false)
              : material.NewSessionPage(routed: true),
        ),
      );
    } else {
      Share.changeBase.broadcast(Value(() => newSessionPage));
    }
  }

  Future<void> _onUseStandaloneCalendar(BuildContext context) async {
    if (_isCreatingCalendar) return;
    setState(() => _isCreatingCalendar = true);
    try {
      await createStandaloneCalendarSession(context: context);
    } catch (e) {
      if (mounted) setState(() => _isCreatingCalendar = false);
    }
  }

  Widget _buildMaterialContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      // Logo container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.12),
                              blurRadius: 32,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/resources/images/logo_fit.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Oshi',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Twój asystent szkolny i nowoczesny terminarz',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Highlights
                      _buildMaterialFeatureItem(
                        context,
                        icon: Icons.calendar_today_rounded,
                        title: 'Plan lekcji i zastępstwa',
                        subtitle: 'Podgląd planu zajęć, sal, zmian oraz odwołanych lekcji.',
                      ),
                      const SizedBox(height: 14),
                      _buildMaterialFeatureItem(
                        context,
                        icon: Icons.grade_rounded,
                        title: 'Oceny, frekwencja i wiadomości',
                        subtitle: 'Wszystkie dane ze szkolnego rejestru zawsze pod ręką.',
                      ),
                      const SizedBox(height: 14),
                      _buildMaterialFeatureItem(
                        context,
                        icon: Icons.edit_calendar_rounded,
                        title: 'Z dziennikiem lub bez niego',
                        subtitle: 'Połącz z Librus / Vulcan albo korzystaj jak z własnego kalendarza.',
                      ),
                      const Spacer(flex: 2),
                      const SizedBox(height: 28),
                      // Buttons
                      FilledButton.icon(
                        onPressed: _isCreatingCalendar ? null : () => _onGetStarted(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'Rozpocznij',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isCreatingCalendar ? null : () => _onUseStandaloneCalendar(context),
                        icon: _isCreatingCalendar
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.calendar_month_outlined),
                        label: Text(
                          _isCreatingCalendar ? 'Konfiguracja...' : 'Używaj bez dziennika (Tylko kalendarz)',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: 0.35,
                        child: Text(
                          Share.buildNumber,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaterialFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCupertinoContent(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 1),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.secondarySystemGroupedBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/resources/images/logo_fit.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Oshi',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Twój asystent szkolny i nowoczesny terminarz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 36),
                      _buildCupertinoFeatureItem(
                        icon: CupertinoIcons.calendar,
                        title: 'Plan lekcji i zastępstwa',
                        subtitle: 'Podgląd planu zajęć, sal, zmian oraz odwołanych lekcji.',
                      ),
                      const SizedBox(height: 12),
                      _buildCupertinoFeatureItem(
                        icon: CupertinoIcons.chart_bar_alt_fill,
                        title: 'Oceny, frekwencja i wiadomości',
                        subtitle: 'Wszystkie dane ze szkolnego rejestru zawsze pod ręką.',
                      ),
                      const SizedBox(height: 12),
                      _buildCupertinoFeatureItem(
                        icon: CupertinoIcons.pencil_ellipsis_rectangle,
                        title: 'Z dziennikiem lub bez niego',
                        subtitle: 'Połącz z Librus / Vulcan albo korzystaj jak z własnego kalendarza.',
                      ),
                      const Spacer(flex: 2),
                      const SizedBox(height: 28),
                      CupertinoButton.filled(
                        onPressed: _isCreatingCalendar ? null : () => _onGetStarted(context),
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Rozpocznij',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 8),
                            Icon(CupertinoIcons.arrow_right, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      CupertinoButton(
                        onPressed: _isCreatingCalendar ? null : () => _onUseStandaloneCalendar(context),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _isCreatingCalendar
                            ? const CupertinoActivityIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(CupertinoIcons.calendar, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Używaj bez dziennika (Tylko kalendarz)',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: 0.35,
                        child: Text(
                          Share.buildNumber,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCupertinoFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CupertinoColors.systemIndigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: CupertinoColors.systemIndigo, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: CupertinoColors.secondaryLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Share.settings.appSettings.useCupertino) {
      final inner = Builder(builder: (context) => _buildCupertinoContent(context));
      if (!widget.asApp) return inner;
      return CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(primaryColor: Color(0xFFbe72e1)),
        home: inner,
      );
    }

    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      ColorScheme? lightColorScheme, darkColorScheme;
      if (lightDynamic != null && darkDynamic != null) {
        (lightColorScheme, darkColorScheme) = generateDynamicColourSchemes(lightDynamic, darkDynamic);
      }

      final inner = Builder(builder: (context) => _buildMaterialContent(context));
      if (!widget.asApp) return inner;

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            },
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme,
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
            },
          ),
        ),
        home: inner,
      );
    });
  }
}

