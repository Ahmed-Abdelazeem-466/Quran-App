import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_strings.dart';

class BrandedQuoteShare {
  static Future<void> sharePngs({
    required List<GlobalKey> repaintKeys,
    required String subject,
    required String text,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final files = <XFile>[];
    for (var index = 0; index < repaintKeys.length; index++) {
      final renderObject = repaintKeys[index].currentContext
          ?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('The share card is not ready yet.');
      }
      final image = await renderObject.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('Unable to create the share image.');
      }
      final output = File(
        '${directory.path}/quran_kareem_quote_${timestamp}_$index.png',
      );
      await output.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      files.add(XFile(output.path, mimeType: 'image/png'));
    }

    await SharePlus.instance.share(
      ShareParams(
        title: subject,
        subject: subject,
        text: text,
        files: files,
        fileNameOverrides: [
          for (var index = 0; index < files.length; index++)
            'quran-kareem-quote-${index + 1}.png',
        ],
      ),
    );
  }
}

class BrandedShareCardData {
  const BrandedShareCardData({
    required this.title,
    required this.reference,
    required this.content,
    required this.contentFontSize,
    this.standaloneBasmala,
  });

  final String title;
  final String reference;
  final String content;
  final double contentFontSize;
  final String? standaloneBasmala;
}

class BrandedQuoteShareSheet extends StatefulWidget {
  const BrandedQuoteShareSheet({
    required this.cards,
    required this.strings,
    super.key,
  });

  final List<BrandedShareCardData> cards;
  final AppStrings strings;

  static Future<void> show(
    BuildContext context, {
    required List<BrandedShareCardData> cards,
    required AppStrings strings,
  }) {
    assert(cards.isNotEmpty);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BrandedQuoteShareSheet(cards: cards, strings: strings),
    );
  }

  @override
  State<BrandedQuoteShareSheet> createState() => _BrandedQuoteShareSheetState();
}

class _BrandedQuoteShareSheetState extends State<BrandedQuoteShareSheet> {
  late List<GlobalKey> _repaintKeys;
  var _isSharing = false;

  @override
  void initState() {
    super.initState();
    _repaintKeys = List<GlobalKey>.generate(
      widget.cards.length,
      (_) => GlobalKey(),
    );
  }

  @override
  void didUpdateWidget(covariant BrandedQuoteShareSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards.length != widget.cards.length) {
      _repaintKeys = List<GlobalKey>.generate(
        widget.cards.length,
        (_) => GlobalKey(),
      );
    }
  }

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      await BrandedQuoteShare.sharePngs(
        repaintKeys: _repaintKeys,
        subject: widget.cards.first.title,
        text: widget.cards
            .map((card) => '${card.title}\n${card.reference}')
            .join('\n\n'),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.cards.length == 1
                  ? widget.strings.sharePreview
                  : '${widget.strings.sharePreview} · ${widget.strings.shareCardsReady(widget.cards.length)}',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (
                      var index = 0;
                      index < widget.cards.length;
                      index++
                    ) ...[
                      RepaintBoundary(
                        key: _repaintKeys[index],
                        child: _BrandedQuoteCard(
                          title: widget.cards[index].title,
                          reference: widget.cards[index].reference,
                          content: widget.cards[index].content,
                          contentFontSize: widget.cards[index].contentFontSize,
                          appTitle: widget.strings.quranAppTitle,
                          standaloneBasmala:
                              widget.cards[index].standaloneBasmala,
                        ),
                      ),
                      if (index < widget.cards.length - 1)
                        const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSharing ? null : _share,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_rounded),
                label: Text(
                  _isSharing
                      ? widget.strings.preparingShareCard
                      : widget.strings.shareNow,
                ),
              ),
            ),
            TextButton(
              onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
              child: Text(
                widget.strings.cancel,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandedQuoteCard extends StatelessWidget {
  const _BrandedQuoteCard({
    required this.title,
    required this.reference,
    required this.content,
    required this.contentFontSize,
    required this.appTitle,
    required this.standaloneBasmala,
  });

  final String title;
  final String reference;
  final String content;
  final double contentFontSize;
  final String appTitle;
  final String? standaloneBasmala;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [colors.primary, colors.secondary],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset('assets/images/icon.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      appTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.format_quote_rounded, size: 28),
                ],
              ),
              const SizedBox(height: 24),
              if (standaloneBasmala != null) ...[
                Text(
                  standaloneBasmala!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: contentFontSize + 3,
                    height: 1.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Text(
                content,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: contentFontSize,
                  height: 1.72,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  reference,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
