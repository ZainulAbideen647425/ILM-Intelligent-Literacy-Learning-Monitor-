import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/session/app_session.dart';
import '../../core/theme/tokens.g.dart';
import '../../shared/widgets/child_tile.dart';
import '../../shared/widgets/filter_bar.dart';
import '../../shared/widgets/ilm_button.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/truck_art.dart';
import '../auth/sign_in_screen.dart';
import '../child_session/child_session_screen.dart';
import 'register_controller.dart';

/// Screen 1 of the Direction B design: the class register.
class ClassRegisterScreen extends StatefulWidget {
  const ClassRegisterScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<ClassRegisterScreen> createState() => _ClassRegisterScreenState();
}

class _ClassRegisterScreenState extends State<ClassRegisterScreen> {
  RegisterController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      final session = SessionScope.read(context);
      _controller = RegisterController(
        repository: session.screening,
        classId: session.classId,
      )..load();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _start(Child child) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ChildSessionScreen(student: child)),
    );
    if (!mounted || completed != true) return;
    _controller!.completeSession(child.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).sessionSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final room = controller.classRoom;
        if (room == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(room: room, onToggleLanguage: widget.onToggleLanguage),
                Expanded(
                  child: _Body(controller: controller, onStart: _start),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _StartBar(room: room, onStart: _start),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.room, this.onToggleLanguage});

  final ClassRoom room;
  final VoidCallback? onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final white = theme.textTheme.bodySmall!.copyWith(color: IlmColors.white);
    return Column(
      children: [
        Container(
          color: IlmColors.aubergine,
          padding: const EdgeInsetsDirectional.fromSTEB(
            IlmSpace.lg,
            IlmSpace.sm,
            IlmSpace.sm,
            IlmSpace.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    s.appName,
                    style: theme.textTheme.titleLarge!.copyWith(
                      color: IlmColors.marigold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${room.savedOfflineCount} ${s.savedOffline}',
                    key: const Key('saved-offline'),
                    style: white,
                  ),
                  LanguageButton(onPressed: onToggleLanguage),
                  IconButton(
                    key: const Key('sign-out'),
                    tooltip: s.signOut,
                    color: IlmColors.white,
                    icon: const Icon(Icons.logout),
                    onPressed: () => SessionScope.read(context).signOut(),
                  ),
                ],
              ),
              const SizedBox(height: IlmSpace.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          textDirection: TextDirection.ltr,
                          style: theme.textTheme.headlineMedium!.copyWith(
                            color: IlmColors.white,
                          ),
                        ),
                        Text(
                          room.nameUr,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: IlmFonts.urdu,
                            fontSize: 16,
                            height: 1.8,
                            color: IlmColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProgressRing(done: room.screenedCount, total: room.total),
                ],
              ),
            ],
          ),
        ),
        const TruckArtBand(),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.controller, required this.onStart});

  final RegisterController controller;
  final ValueChanged<Child> onStart;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final room = controller.classRoom!;
    final children = controller.visibleChildren;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            IlmSpace.lg,
            IlmSpace.lg,
            IlmSpace.lg,
            IlmSpace.md,
          ),
          sliver: SliverToBoxAdapter(
            child: FilterBar<RegisterFilter>(
              selected: controller.filter,
              onChanged: controller.setFilter,
              options: [
                FilterOption(
                  value: RegisterFilter.everyone,
                  label: s.filterEveryone,
                ),
                FilterOption(
                  value: RegisterFilter.followUp,
                  label: s.signalFollowUp,
                  count: room.countOf(Signal.followUp),
                ),
                FilterOption(
                  value: RegisterFilter.notYet,
                  label: s.signalNotYet,
                  count: room.countOf(Signal.notYet),
                ),
              ],
            ),
          ),
        ),
        if (children.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(IlmSpace.xl),
              child: Text(s.noChildrenInFilter, textAlign: TextAlign.center),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              IlmSpace.lg,
              0,
              IlmSpace.lg,
              IlmSpace.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: TileRows(
                tiles: [
                  for (final child in children)
                    ChildTile(
                      key: ValueKey('tile-${child.id}'),
                      student: child,
                      onTap: child.canStart ? () => onStart(child) : null,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StartBar extends StatelessWidget {
  const _StartBar({required this.room, required this.onStart});

  final ClassRoom room;
  final ValueChanged<Child> onStart;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final next = room.nextChild;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          IlmSpace.lg,
          IlmSpace.sm,
          IlmSpace.lg,
          IlmSpace.lg,
        ),
        child: next == null
            ? Text(
                s.allScreened,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              )
            : IlmButton(
                key: const Key('start-next'),
                label: '${s.startWith} ${next.firstName}',
                icon: Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back
                    : Icons.arrow_forward,
                onPressed: () => onStart(next),
              ),
      ),
    );
  }
}
