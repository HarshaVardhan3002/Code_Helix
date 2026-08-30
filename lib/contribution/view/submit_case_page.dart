import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/view/triage_result_page.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/session/session.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template submit_case_page}
/// The case submission form.
///
/// This is the Instagram post composer repurposed, and the important
/// difference is what it does **not** have: an upload button. A physician
/// uploading their own endoscopy frame is uploading patient data, and a
/// consent pipeline is not something to improvise for a hackathon. Authors
/// pick from the licensed library and write the case around the image.
/// {@endtemplate}
class SubmitCasePage extends StatefulWidget {
  /// {@macro submit_case_page}
  const SubmitCasePage({super.key});

  @override
  State<SubmitCasePage> createState() => _SubmitCasePageState();
}

class _SubmitCasePageState extends State<SubmitCasePage> {
  final _question = TextEditingController();
  final _revealTitle = TextEditingController();
  final _explanation = TextEditingController();
  final _takeaway = TextEditingController();
  final _recommendation = TextEditingController();
  final _optionLabels = List.generate(4, (_) => TextEditingController());
  final _optionRationales = List.generate(4, (_) => TextEditingController());

  LibraryImage? _image;
  GuidelineTopic? _topic;
  QuizFocus _focus = QuizFocus.befund;
  int _correctIndex = 0;

  @override
  void dispose() {
    _question.dispose();
    _revealTitle.dispose();
    _explanation.dispose();
    _takeaway.dispose();
    _recommendation.dispose();
    for (final controller in [..._optionLabels, ..._optionRationales]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isComplete =>
      _image != null &&
      _topic != null &&
      _question.text.trim().isNotEmpty &&
      _revealTitle.text.trim().isNotEmpty &&
      _explanation.text.trim().isNotEmpty &&
      _optionLabels.every((c) => c.text.trim().isNotEmpty);

  /// Fills the form with a complete, realistic draft.
  ///
  /// Purely a demo affordance, and labelled as one. Typing a Facharzt-level
  /// case on stage would burn the whole ten minutes; the loop being
  /// demonstrated is submit → screen → approve → appear, not touch typing.
  void _fillExample(Catalog catalog) {
    setState(() {
      _image = catalog.images.firstWhere(
        (image) => image.id == 'img-terminales-ileum',
        orElse: () => catalog.images.first,
      );
      _topic = catalog.topicById('morbus-crohn-befall') ?? catalog.topics.first;
      _focus = QuizFocus.befund;
      _correctIndex = 2;
      _question.text =
          'Welcher Befund spricht hier gegen eine Colitis ulcerosa?';
      _revealTitle.text =
          'Aphthoide Läsionen im terminalen Ileum bei ausgespartem Rektum';
      _explanation.text =
          'Ileokoloskopie bei rechtsseitigen Unterbauchschmerzen und '
          'Gewichtsverlust. Im terminalen Ileum aphthoide Läsionen und '
          'längsgerichtete Ulzerationen mit dazwischen unauffälliger '
          'Schleimhaut. Das Rektum ist vollständig ausgespart, im Kolon '
          'wechseln befallene und unbefallene Abschnitte.\n\n'
          'Die Kombination aus Ileumbefall, Diskontinuität und ausgespartem '
          'Rektum ist mit einer Colitis ulcerosa nicht vereinbar. Die '
          'endgültige Zuordnung erfolgt in der Zusammenschau aus Endoskopie, '
          'Histologie, Bildgebung und Klinik.';
      _takeaway.text =
          'Ausgespartes Rektum plus Ileumbefall schließt eine Colitis '
          'ulcerosa praktisch aus.';
      _optionLabels[0].text = 'Die aufgehobene Gefäßzeichnung';
      _optionRationales[0].text =
          'Unspezifisch. Eine aufgehobene Gefäßzeichnung findet sich bei '
          'jeder floriden Kolitis und trennt die beiden Entitäten nicht.';
      _optionLabels[1].text = 'Die Kontaktblutung der Schleimhaut';
      _optionRationales[1].text =
          'Unspezifisch. Vulnerabilität ist ein Aktivitätsmerkmal, kein '
          'Zuordnungsmerkmal, und kommt bei beiden Erkrankungen vor.';
      _optionLabels[2].text =
          'Der Ileumbefall bei vollständig ausgespartem Rektum';
      _optionRationales[2].text =
          'Richtig. Die Colitis ulcerosa beginnt im Rektum und steigt '
          'kontinuierlich auf. Ein ausgespartes Rektum zusammen mit einem '
          'Befall des terminalen Ileums passt zum Morbus Crohn und ist mit '
          'einer Colitis ulcerosa nicht vereinbar.';
      _optionLabels[3].text = 'Das Ödem der Schleimhaut';
      _optionRationales[3].text =
          'Unspezifisch. Ein Schleimhautödem begleitet nahezu jede '
          'entzündliche Veränderung und erlaubt keine Zuordnung.';
    });
  }

  Future<void> _submit(BuildContext context) async {
    final catalogCubit = context.read<CatalogCubit>();
    final navigator = Navigator.of(context);
    final author = context.read<SessionCubit>().state?.name ?? 'Unbekannt';
    final topic = _topic!;
    final image = _image!;

    final recommendation = _recommendation.text.trim();

    final submitted = DailyCase(
      id: 'case-${DateTime.now().microsecondsSinceEpoch}',
      imageAsset: image.asset,
      imageCredit: image.credit,
      region: image.region,
      topicId: topic.id,
      contributedBy: author,
      revealTitle: _revealTitle.text.trim(),
      explanation: _explanation.text.trim(),
      citation: GuidelineCitation(
        guideline: topic.citation.guideline,
        register: topic.citation.register,
        version: topic.citation.version,
        recommendation: recommendation.isEmpty ? null : recommendation,
      ),
      quiz: CaseQuiz(
        focus: _focus,
        question: _question.text.trim(),
        correctOptionId: 'o$_correctIndex',
        takeaway: _takeaway.text.trim(),
        options: [
          for (var index = 0; index < 4; index++)
            QuizOption(
              id: 'o$index',
              label: _optionLabels[index].text.trim(),
              rationale: _optionRationales[index].text.trim(),
            ),
        ],
      ),
    );

    final submission = await catalogCubit.submit(
      submitted: submitted,
      authorName: author,
    );

    if (!mounted) return;
    await navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TriageResultPage(submission: submission),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SurfaceBackground(
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            if (state.screening) return const _Screening();

            return Stack(
              fit: StackFit.expand,
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    ShellMetrics.topInset(context),
                    AppSpacing.lg,
                    AppSpacing.xxxlg,
                  ),
                  children: [
                    Text(
                      'Fall einreichen',
                      style: context.headlineSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: AppFontWeight.semiBold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Bild aus der lizenzierten Sammlung wählen, Frage und '
                      'vier Optionen schreiben, Quelle zuordnen.',
                      style: context.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.6),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ExampleButton(onTap: () => _fillExample(state.catalog)),
                    const SizedBox(height: AppSpacing.xlg),
                    _ImagePicker(
                      images: state.catalog.images,
                      selected: _image,
                      onSelected: (image) => setState(() => _image = image),
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    _FocusPicker(
                      focus: _focus,
                      onSelected: (focus) => setState(() => _focus = focus),
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    ContributionField(
                      label: 'Frage',
                      controller: _question,
                      hint: 'Was sehen wir endoskopisch?',
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    _OptionsEditor(
                      labels: _optionLabels,
                      rationales: _optionRationales,
                      correctIndex: _correctIndex,
                      onCorrectChanged: (index) =>
                          setState(() => _correctIndex = index),
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    ContributionField(
                      label: 'Auflösung — Überschrift',
                      controller: _revealTitle,
                      helper: 'Wird erst nach der Antwort angezeigt.',
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ContributionField(
                      label: 'Auflösung — Falltext',
                      controller: _explanation,
                      minLines: 5,
                      maxLines: 12,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ContributionField(
                      label: 'Merksatz',
                      controller: _takeaway,
                      minLines: 2,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    _TopicPicker(
                      topics: state.catalog.topics,
                      selected: _topic,
                      onSelected: (topic) => setState(() => _topic = topic),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ContributionField(
                      label: 'Empfehlungsnummer (optional)',
                      controller: _recommendation,
                      hint: 'z. B. 3.14',
                      helper:
                          'Fehlt sie, wird die Antwort als „Empfehlung '
                          '[offen]“ ausgewiesen und die Vorprüfung markiert '
                          'es.',
                    ),
                    const SizedBox(height: AppSpacing.xxlg),
                    _SubmitButton(
                      enabled: _isComplete,
                      onTap: () => _submit(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nichts wird veröffentlicht, bevor die ärztliche '
                      'Redaktion freigegeben hat.',
                      textAlign: TextAlign.center,
                      style: context.labelSmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.4),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                const StatusBarScrim(),
                const _BackButton(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Screening extends StatelessWidget {
  const _Screening();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppCircularProgress(AppColors.white),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Vorprüfung läuft',
            style: context.titleSmall?.copyWith(
              color: AppColors.white,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Der Fall wird gegen die zugeordnete Leitlinie abgeglichen.',
            textAlign: TextAlign.center,
            style: context.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleButton extends StatelessWidget {
  const _ExampleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_outlined,
              size: 16,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Beispielfall einsetzen (Demo)',
              style: context.labelMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.images,
    required this.selected,
    required this.onSelected,
  });

  final List<LibraryImage> images;
  final LibraryImage? selected;
  final ValueChanged<LibraryImage> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILD AUS DER SAMMLUNG',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.45),
            letterSpacing: 1.4,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final image = images[index];
              final active = image.id == selected?.id;

              return Tappable.scaled(
                onTap: () => onSelected(image),
                child: SizedBox(
                  width: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 68,
                        // Without an explicit width the tile collapses to its
                        // child, and the missing-asset placeholder has no
                        // intrinsic size — the picker renders as hairlines.
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                          border: Border.all(
                            color: AppColors.white.withValues(
                              alpha: active ? 0.85 : 0.14,
                            ),
                            width: active ? 1.6 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          image.asset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, _) => const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF5C3A3C), Color(0xFF16181D)],
                              ),
                            ),
                            child: SizedBox.expand(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        image.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.labelSmall?.copyWith(
                          color: AppColors.white.withValues(
                            alpha: active ? 0.9 : 0.5,
                          ),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Kein Upload: eigene Aufnahmen sind Patientendaten. '
          'Einwilligungsstrecke ist Roadmap.',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.4),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _FocusPicker extends StatelessWidget {
  const _FocusPicker({required this.focus, required this.onSelected});

  final QuizFocus focus;
  final ValueChanged<QuizFocus> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FRAGETYP',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.45),
            letterSpacing: 1.4,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final value in QuizFocus.values)
              Tappable.faded(
                onTap: () => onSelected(value),
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(
                      alpha: value == focus ? 0.16 : 0.05,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    border: Border.all(
                      color: AppColors.white.withValues(
                        alpha: value == focus ? 0.4 : 0.12,
                      ),
                    ),
                  ),
                  child: Text(
                    value.label,
                    style: context.labelMedium?.copyWith(
                      color: AppColors.white.withValues(
                        alpha: value == focus ? 1 : 0.68,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionsEditor extends StatelessWidget {
  const _OptionsEditor({
    required this.labels,
    required this.rationales,
    required this.correctIndex,
    required this.onCorrectChanged,
  });

  final List<TextEditingController> labels;
  final List<TextEditingController> rationales;
  final int correctIndex;
  final ValueChanged<int> onCorrectChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VIER OPTIONEN',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.45),
            letterSpacing: 1.4,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Jede Option braucht eine Begründung — auch die falschen. '
          'Alle vier werden nach der Antwort angezeigt.',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.4),
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < labels.length; index++) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(
                color: AppColors.white.withValues(
                  alpha: index == correctIndex ? 0.3 : 0.1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Tappable.faded(
                      onTap: () => onCorrectChanged(index),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            index == correctIndex
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 17,
                            color: index == correctIndex
                                ? kVerdictCorrect
                                : AppColors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            index == correctIndex
                                ? 'Richtige Antwort'
                                : 'Als richtig markieren',
                            style: context.labelSmall?.copyWith(
                              color: index == correctIndex
                                  ? kVerdictCorrect
                                  : AppColors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ContributionField(
                  label: 'Option ${index + 1}',
                  controller: labels[index],
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.sm),
                ContributionField(
                  label: 'Begründung',
                  controller: rationales[index],
                  minLines: 2,
                  maxLines: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _TopicPicker extends StatelessWidget {
  const _TopicPicker({
    required this.topics,
    required this.selected,
    required this.onSelected,
  });

  final List<GuidelineTopic> topics;
  final GuidelineTopic? selected;
  final ValueChanged<GuidelineTopic> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUELLE ZUORDNEN',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.45),
            letterSpacing: 1.4,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final topic in topics) ...[
          Tappable.faded(
            onTap: () => onSelected(topic),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(
                  alpha: topic.id == selected?.id ? 0.09 : 0.03,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(
                  color: AppColors.white.withValues(
                    alpha: topic.id == selected?.id ? 0.35 : 0.1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    topic.id == selected?.id
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: AppColors.white.withValues(
                      alpha: topic.id == selected?.id ? 0.9 : 0.35,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: context.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 2),
                        CitationBlock(citation: topic.citation, dense: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: enabled ? 0.92 : 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Text(
          'Zur Vorprüfung einreichen',
          style: context.titleSmall?.copyWith(
            color: enabled
                ? const Color(0xFF0B0F14)
                : AppColors.white.withValues(alpha: 0.4),
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Tappable.scaled(
            onTap: Navigator.of(context).pop,
            child: const GlassSurface(
              level: GlassLevel.chip,
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
