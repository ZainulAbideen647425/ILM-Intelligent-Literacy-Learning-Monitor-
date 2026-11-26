import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/tokens.g.dart';
import '../../shared/widgets/bead_progress.dart';
import '../../shared/widgets/child_tile.dart';
import '../../shared/widgets/filter_bar.dart';
import '../../shared/widgets/ilm_button.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/result_widgets.dart';
import '../../shared/widgets/signal_chip.dart';
import '../../shared/widgets/truck_art.dart';

/// Phase F1 deliverable: every Direction B component on one screen, in both
/// languages. Replaced as the app's home screen in F2.
class ComponentGalleryScreen extends StatefulWidget {
  const ComponentGalleryScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<ComponentGalleryScreen> createState() => _ComponentGalleryScreenState();
}

enum _Filter { everyone, followUp, notYet }

class _ComponentGalleryScreenState extends State<ComponentGalleryScreen> {
  _Filter _filter = _Filter.everyone;

  static const _samples = [
    Child(
        id: 's1',
        displayName: 'Areeba Khan',
        signal: Signal.followUp,
        hasConsent: true),
    Child(
        id: 's2',
        displayName: 'Faraz Malik',
        signal: Signal.watch,
        hasConsent: true),
    Child(
        id: 's3',
        displayName: 'Hania Qureshi',
        signal: Signal.allClear,
        hasConsent: true),
    Child(
        id: 's4',
        displayName: 'Noor Fatima',
        signal: Signal.notYet,
        hasConsent: true,
        isNextUp: true),
    Child(
        id: 's5',
        displayName: 'Saad Rehman',
        signal: Signal.notYet,
        hasConsent: false),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: IlmSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: IlmSpace.md),
              child,
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(s.componentGallery),
        actions: [
          TextButton(
            key: const Key('toggle-language'),
            onPressed: widget.onToggleLanguage,
            style: TextButton.styleFrom(
              foregroundColor: IlmColors.white,
              minimumSize:
                  const Size(IlmSize.minTouchTarget, IlmSize.minTouchTarget),
            ),
            child: Text(s.isUrdu ? 'English' : 'اردو'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(IlmSpace.lg),
        children: [
          section(
            'Header',
            Container(
              color: IlmColors.aubergine,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(IlmSpace.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.appName,
                            style: theme.textTheme.headlineMedium!
                                .copyWith(color: IlmColors.marigold),
                          ),
                        ),
                        const ProgressRing(done: 18, total: 32),
                      ],
                    ),
                  ),
                  const TruckArtBand(),
                ],
              ),
            ),
          ),
          section(
            'Signals',
            const Wrap(
              spacing: IlmSpace.lg,
              runSpacing: IlmSpace.sm,
              children: [
                SignalChip(signal: Signal.followUp),
                SignalChip(signal: Signal.watch),
                SignalChip(signal: Signal.allClear),
                SignalChip(signal: Signal.notYet),
              ],
            ),
          ),
          section(
            'Filters',
            FilterBar<_Filter>(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
              options: [
                FilterOption(value: _Filter.everyone, label: s.filterEveryone),
                FilterOption(
                    value: _Filter.followUp, label: s.signalFollowUp, count: 2),
                FilterOption(
                    value: _Filter.notYet, label: s.signalNotYet, count: 14),
              ],
            ),
          ),
          section(
            'Child tiles',
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: IlmSpace.md,
              crossAxisSpacing: IlmSpace.md,
              childAspectRatio: 1.1,
              children: [
                for (final c in _samples) ChildTile(student: c, onTap: () {}),
              ],
            ),
          ),
          section(
            'Buttons',
            Column(
              children: [
                IlmButton(
                  label: '${s.startWith} Noor',
                  icon: Icons.arrow_forward,
                  onPressed: () {},
                ),
                const SizedBox(height: IlmSpace.md),
                Row(
                  children: [
                    Expanded(
                      child: IlmButton(
                        label: s.again,
                        variant: IlmButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: IlmSpace.md),
                    Expanded(
                      child: IlmButton(
                        label: s.done,
                        icon: Icons.check,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          section('Bead progress', const BeadProgress(current: 2, total: 6)),
          section(
            'Writing frame',
            TruckArtFrame(
              child: SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    s.useYourFinger,
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: IlmColors.inkMuted),
                  ),
                ),
              ),
            ),
          ),
          section(
            'Result',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MedallionBadge(signal: Signal.followUp),
                const SizedBox(height: IlmSpace.md),
                Text(s.screeningNotDiagnosis,
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: IlmSpace.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LevelGauge(level: Level.many, caption: s.writing),
                    LevelGauge(level: Level.some, caption: s.reading),
                  ],
                ),
                const SizedBox(height: IlmSpace.md),
                const ObservationRow(
                  text: 'Mixed up ب and پ in several letters',
                  signal: Signal.followUp,
                ),
                const ObservationRow(
                  text: 'Paused often while reading aloud',
                  signal: Signal.watch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
