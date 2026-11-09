import 'package:flutter/material.dart';

import '../data/waqf_marks.dart';
import '../localization/app_strings.dart';

class WaqfMarksScreen extends StatelessWidget {
  const WaqfMarksScreen({required this.language, super.key});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final content = waqfMarksContentFor(language);
    final referenceSections = waqfReferenceSectionsFor(language);
    final referenceDetails = waqfMarkReferenceDetailsFor(language);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.pause_circle_outline_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        content.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content.intro,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              sliver: SliverToBoxAdapter(
                child: _ArabicReferenceSection(
                  section: referenceSections.first,
                  textDirection: language.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              sliver: SliverList.separated(
                itemCount: waqfMarkDefinitions.length,
                itemBuilder: (context, index) => _WaqfMarkCard(
                  definition: waqfMarkDefinitions[index],
                  explanation: content.explanations[index],
                  referenceDetail: referenceDetails[index],
                  textDirection: language.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
              sliver: SliverList.separated(
                itemCount: referenceSections.length - 1,
                itemBuilder: (context, index) => _ArabicReferenceSection(
                  section: referenceSections[index + 1],
                  textDirection: language.isRtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 28),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.55),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${content.note}\n\n${content.teacherNote}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaqfMarkCard extends StatelessWidget {
  const _WaqfMarkCard({
    required this.definition,
    required this.explanation,
    required this.referenceDetail,
    required this.textDirection,
  });

  final WaqfMarkDefinition definition;
  final String explanation;
  final WaqfMarkReferenceDetail referenceDetail;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 66,
              height: 66,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  definition.symbol,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontFamily: 'NotoNaskhArabic',
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      definition.arabicName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'NotoNaskhArabic',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    explanation,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: textDirection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          referenceDetail.beforeExample,
                          textAlign: textDirection == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.65),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                definition.quranExample,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontFamily: 'NotoNaskhArabic',
                                      height: 1.9,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                definition.quranReference,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: colors.onSecondaryContainer,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          referenceDetail.afterExample,
                          textAlign: textDirection == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(height: 1.65),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArabicReferenceSection extends StatelessWidget {
  const _ArabicReferenceSection({
    required this.section,
    required this.textDirection,
  });

  final WaqfReferenceSection section;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      padding: const EdgeInsets.all(18),
      child: Directionality(
        textDirection: textDirection,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              section.title,
              textAlign: textDirection == TextDirection.rtl
                  ? TextAlign.right
                  : TextAlign.left,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final paragraph in section.paragraphs) ...[
              Text(
                paragraph,
                textAlign: textDirection == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.8),
              ),
              const SizedBox(height: 12),
            ],
            for (final bullet in section.bullets) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bullet,
                      textAlign: textDirection == TextDirection.rtl
                          ? TextAlign.right
                          : TextAlign.left,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(height: 1.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
