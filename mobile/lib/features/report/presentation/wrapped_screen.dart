import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/icons.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/mascot.dart';
import '../../../core/widgets/state_views.dart';
import '../../activity/data/activity_models.dart';
import '../../attachment/data/attachment_models.dart';
import '../../activity/providers/activity_providers.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../../dashboard/data/dashboard_models.dart';
import '../data/report_models.dart';
import '../providers/report_providers.dart';

/// Hari dengan pengeluaran terbesar; null jika tidak ada pengeluaran.
/// Seri sama besar: tanggal paling awal.
SeriesPoint? busiestDay(List<SeriesPoint> series) {
  SeriesPoint? best;
  for (final point in series) {
    if (point.expense > (best?.expense ?? 0)) best = point;
  }
  return best;
}

/// Maks. [count] foto acak dari semua kegiatan bulan itu.
List<Attachment> pickPhotos(
  List<Activity> activities,
  Random random, {
  int count = 4,
}) => ([
  for (final activity in activities) ...activity.attachments,
]..shuffle(random)).take(count).toList();

/// Rekap bulanan ala "wrapped" (ENG-04, D-72). [month] = `YYYY-MM`.
/// Selalu semua dompet, tidak mengikuti filter dompet Laporan.
class WrappedScreen extends ConsumerStatefulWidget {
  const WrappedScreen({super.key, required this.month});

  final String month;

  @override
  ConsumerState<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends ConsumerState<WrappedScreen> {
  var _page = 0;
  // Acak sekali per buka layar; tap kartu tidak mengganti foto.
  final _seed = Random().nextInt(1 << 31);

  @override
  Widget build(BuildContext context) {
    final reportP = reportProvider(ReportType.monthly, widget.month);
    final activitiesP = monthActivitiesProvider(widget.month);
    final report = ref.watch(reportP);
    final activities = ref.watch(activitiesP);
    final monthName = formatMonth(DateTime.parse('${widget.month}-01'));

    Widget body;
    if (report.hasError || activities.hasError) {
      body = ErrorState(
        error: (report.error ?? activities.error)!,
        onRetry: () {
          ref.invalidate(reportP);
          ref.invalidate(activitiesP);
        },
      );
    } else if (report.value == null || activities.value == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final posters = _posters(report.value!, activities.value!, monthName);
      final total = posters.length + 1;
      final last = _page == total - 1;
      // Tap / geser kiri = kartu berikutnya, geser kanan = sebelumnya.
      // Kartu terakhir (ringkasan) ditutup lewat tombol Selesai.
      void go(int page) => setState(() => _page = page.clamp(0, total - 1));
      body = Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.lg,
                Spacing.lg,
                Spacing.xxl,
              ),
              child: GestureDetector(
                key: const Key('wrappedCards'),
                behavior: HitTestBehavior.opaque,
                onTap: () => go(_page + 1),
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < 0) go(_page + 1);
                  if (velocity > 0) go(_page - 1);
                },
                child: _CardStack(
                  index: _page,
                  colors: [
                    for (final poster in posters) poster.color,
                    Theme.of(context).colorScheme.surface,
                  ],
                  front: last
                      ? _SummaryView(
                          month: monthName,
                          posters: posters,
                          total: total,
                          onOpen: go,
                        )
                      : _PosterView(
                          card: posters[_page],
                          number: _page + 1,
                          total: total,
                        ),
                ),
              ),
            ),
          ),
          _Dots(count: total, active: _page),
          const SizedBox(height: Spacing.sm),
          Text(
            last ? 'Tap kartu kecil buat lihat lagi' : 'Tap kartu buat lanjut',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.of(context).textSecondary),
          ),
          const SizedBox(height: Spacing.lg),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Rekap $monthName')),
      body: SafeArea(top: false, child: body),
    );
  }

  List<_Poster> _posters(
    Report report,
    List<Activity> activities,
    String month,
  ) {
    final colors = AppColors.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    Color wash(Color color) =>
        Color.alphaBlend(color.withValues(alpha: 0.3), surface);
    final totals = report.totals;
    final top = report.byCategory.firstOrNull;
    final day = busiestDay(report.series);
    final dayDate = day == null ? null : DateTime.parse(day.label);
    final photos = pickPhotos(activities, Random(_seed));
    final photoCount = activities.fold(
      0,
      (sum, activity) => sum + activity.attachments.length,
    );
    final pct = report.comparison?.changePct;
    final net = totals.net;
    String signed(int amount) =>
        '${amount > 0 ? '+' : ''}${formatCompact(amount)}';
    return [
      _Poster(
        color: colors.expenseTint,
        icon: Icons.receipt_long_rounded,
        label: '$month kamu keluar',
        hero: formatCompact(totals.expense),
        sub: totals.expense == 0
            ? 'Belum ada pengeluaran. Hemat banget!'
            : formatRupiah(totals.expense),
        stickers: [
          if (totals.expense > 0 && pct == null)
            const _Sticker('Bulan lalu kosong'),
          if (totals.expense > 0 && pct != null)
            _Sticker(
              pct.round() == 0
                  ? 'Sama kayak bulan lalu'
                  : '${pct > 0 ? 'Naik' : 'Turun'} ${pct.abs().round()}% dari bulan lalu',
              icon: pct > 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: pct > 0 ? colors.heatmap[2] : colors.incomeTint,
            ),
        ],
        mascot: pct != null && pct < 0
            ? MascotExpression.happy
            : MascotExpression.neutral,
        summaryLabel: 'Keluar',
        summaryValue: formatCompact(totals.expense),
      ),
      _Poster(
        color: top == null
            ? colors.importantTint
            : wash(colorFromHex(top.category.color)),
        icon: top == null ? Icons.category_rounded : iconFor(top.category.icon),
        label: 'Kategori terboros',
        hero: top?.category.name ?? '–',
        sub: top == null
            ? 'Belum ada pengeluaran, jadi belum ada juaranya.'
            : formatRupiah(top.amount),
        stickers: [
          if (top != null)
            _Sticker(
              '${(top.share * 100).round()}% dari semua pengeluaran',
              icon: Icons.pie_chart_rounded,
            ),
        ],
        layout: _Layout.badge,
        summaryLabel: 'Terboros',
        summaryValue: top?.category.name ?? '–',
      ),
      _Poster(
        color: colors.heatmap.last,
        icon: Icons.local_fire_department_rounded,
        label: 'Hari paling boros',
        hero: dayDate == null ? '–' : '${dayDate.day}',
        sub: dayDate == null
            ? 'Nggak ada hari yang boros bulan ini.'
            : formatLongDate(dayDate),
        stickers: [
          if (day != null)
            _Sticker(
              'Keluar ${formatRupiah(day.expense)}',
              icon: Icons.payments_rounded,
            ),
        ],
        layout: _Layout.calendar,
        badge: dayDate == null ? null : formatWeekday(dayDate),
        summaryLabel: 'Paling boros',
        summaryValue: dayDate == null ? '–' : formatShortDate(dayDate),
      ),
      _Poster(
        color: wash(colors.activity),
        icon: Icons.photo_camera_rounded,
        label: 'Kegiatan $month',
        hero: '${activities.length}',
        sub: photoCount == 0
            ? 'kegiatan, belum ada yang berfoto.'
            : 'kegiatan, $photoCount foto kenangan.',
        extra: photos.isEmpty ? null : _PhotoGrid(photos),
        layout: _Layout.photos,
        summaryLabel: 'Kegiatan',
        summaryValue: '$photoCount foto',
      ),
      _Poster(
        color: colors.incomeTint,
        icon: Icons.savings_rounded,
        label: 'Selisih $month',
        hero: signed(net),
        sub: net >= 0
            ? 'Masih surplus, mantap!'
            : 'Minus, bulan depan pelan-pelan ya.',
        stickers: [
          _Sticker(
            'Masuk ${formatRupiah(totals.income)}',
            icon: Icons.south_west_rounded,
          ),
          _Sticker(
            'Keluar ${formatRupiah(totals.expense)}',
            icon: Icons.north_east_rounded,
          ),
        ],
        mascot: net >= 0 ? MascotExpression.happy : MascotExpression.neutral,
        layout: _Layout.closing,
        summaryLabel: 'Selisih',
        summaryValue: signed(net),
      ),
    ];
  }
}

/// Kartu depan lurus; maks. 2 kartu berikutnya di belakang, miring tipis
/// dengan warnanya. Kartu baru maju dari belakang, kartu lama terlempar ke kiri.
class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.index,
    required this.colors,
    required this.front,
  });

  final int index;
  final List<Color> colors;
  final Widget front;

  // Sudut (radian) dan geser kartu belakang ke-1 dan ke-2.
  static const _tilt = [0.07, -0.1];
  static const _shift = [Offset(6, 4), Offset(-6, 6)];

  @override
  Widget build(BuildContext context) {
    Widget behind(int depth) => Transform.translate(
      offset: _shift[depth - 1],
      child: Transform.rotate(
        angle: _tilt[depth - 1],
        child: FrameCard(
          color: colors[index + depth],
          child: const SizedBox.expand(),
        ),
      ),
    );
    final remaining = colors.length - 1 - index;
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var depth = remaining.clamp(0, 2); depth > 0; depth--)
          behind(depth),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (card, animation) {
            final incoming = card.key == ValueKey(index);
            return incoming
                ? RotationTransition(
                    turns: Tween(
                      begin: _tilt[0] / (2 * pi),
                      end: 0.0,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: card),
                  )
                : SlideTransition(
                    position: Tween(
                      begin: const Offset(-1.2, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: card,
                  );
          },
          child: KeyedSubtree(key: ValueKey(index), child: front),
        ),
      ],
    );
  }
}

/// Isi satu kartu poster.
class _Poster {
  const _Poster({
    required this.color,
    required this.icon,
    required this.label,
    required this.hero,
    required this.sub,
    required this.summaryLabel,
    required this.summaryValue,
    this.layout = _Layout.hero,
    this.badge,
    this.stickers = const [],
    this.extra,
    this.mascot,
  });

  final _Layout layout;

  /// Teks strip atas sobekan kalender (tata letak calendar).
  final String? badge;

  /// Latar seluruh kartu; teks di atasnya = onSurface.
  final Color color;
  final IconData icon;
  final String label;

  /// Angka/judul raksasa; mengecil sendiri bila tidak muat.
  final String hero;
  final String sub;
  final List<_Sticker> stickers;

  /// Mengisi sisa tinggi kartu (mis. grid foto).
  final Widget? extra;
  final MascotExpression? mascot;

  /// Isi kartu mini di ringkasan.
  final String summaryLabel;
  final String summaryValue;
}

/// Kartu berframe dengan isi di dalam garis frame (warna tidak menutupi garis).
class _Framed extends StatelessWidget {
  const _Framed({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = AppStyle.of(context);
    return FrameCard(
      padding: EdgeInsets.all(style.frameWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          max(0, style.cardRadius - style.frameWidth * 2),
        ),
        child: ColoredBox(color: color, child: child),
      ),
    );
  }
}

/// Tata letak poster; konsep sama, komposisi beda per kartu.
enum _Layout {
  /// Angka raksasa kiri, lingkaran kanan atas, maskot pojok kanan bawah.
  hero,

  /// Ikon besar di tengah dalam lingkaran, teks rata tengah.
  badge,

  /// Sobekan kalender raksasa miring, teks di bawahnya.
  calendar,

  /// Foto polaroid di atas, angka di bawah.
  photos,

  /// Maskot besar di atas, angka rata tengah, setengah lingkaran di bawah.
  closing,
}

class _PosterView extends StatelessWidget {
  const _PosterView({
    required this.card,
    required this.number,
    required this.total,
  });

  final _Poster card;
  final int number;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;
    final base = theme.textTheme.displayMedium!;
    // Bentuk dekor = warna kartu dicampur latar tema.
    final decor = Color.alphaBlend(surface.withValues(alpha: 0.4), card.color);
    final ring = ink.withValues(alpha: 0.25);
    final centered = switch (card.layout) {
      _Layout.badge || _Layout.closing => true,
      _ => false,
    };
    final align = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    Widget heroText([double scale = 2.25]) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        card.hero,
        maxLines: 1,
        style: base.copyWith(
          color: ink,
          fontSize: (base.fontSize ?? 32) * scale,
          height: 1.1,
        ),
      ),
    );
    final texts = <Widget>[
      Text(
        card.label,
        textAlign: textAlign,
        style: theme.textTheme.titleMedium?.copyWith(color: ink),
      ),
      heroText(card.layout == _Layout.calendar ? 1.2 : 2.25),
      Text(
        card.sub,
        textAlign: textAlign,
        style: theme.textTheme.bodyLarge?.copyWith(color: ink),
      ),
      if (card.stickers.isNotEmpty) ...[
        const SizedBox(height: Spacing.md),
        Wrap(
          alignment: centered ? WrapAlignment.center : WrapAlignment.start,
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final (i, sticker) in card.stickers.indexed)
              Transform.rotate(angle: i.isEven ? -0.05 : 0.04, child: sticker),
          ],
        ),
      ],
    ];
    final top = Row(
      children: [
        _Sticker('$number / $total', color: surface),
        const Spacer(),
        Icon(card.icon, color: ink),
      ],
    );

    return _Framed(
      color: card.color,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          // Isi utama mengecil utuh bila kartu pendek, tanpa terpotong.
          List<Widget> fitted(Alignment at, List<Widget> children) => [
            Expanded(
              child: Align(
                alignment: at,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: at,
                  child: SizedBox(
                    width: w - Spacing.lg * 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: align,
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ];
          final (decorations, body) = switch (card.layout) {
            _Layout.hero => (
              [
                Positioned(
                  top: -w * 0.25,
                  right: -w * 0.3,
                  child: _Blob(size: w * 0.8, color: decor),
                ),
                Positioned(
                  left: -w * 0.12,
                  bottom: h * 0.18,
                  child: _Blob(size: w * 0.3, ring: ring),
                ),
                if (card.mascot case final mood?)
                  Positioned(
                    right: -w * 0.04,
                    bottom: -w * 0.06,
                    child: Mascot(size: w * 0.42, expression: mood),
                  ),
              ],
              fitted(const Alignment(-1, -0.2), texts),
            ),
            _Layout.badge => (
              [
                Positioned(
                  left: -w * 0.2,
                  bottom: -w * 0.2,
                  child: _Blob(size: w * 0.7, color: decor),
                ),
                Positioned(
                  right: -w * 0.1,
                  top: h * 0.3,
                  child: _Blob(size: w * 0.25, ring: ring),
                ),
              ],
              fitted(const Alignment(0, -0.3), [
                _IconBadge(icon: card.icon, size: w * 0.38),
                const SizedBox(height: Spacing.lg),
                ...texts,
              ]),
            ),
            _Layout.calendar => (
              [
                Positioned(
                  right: -w * 0.15,
                  top: -w * 0.15,
                  child: _Blob(size: w * 0.5, ring: ring),
                ),
                Positioned(
                  right: -w * 0.25,
                  bottom: -w * 0.25,
                  child: _Blob(size: w * 0.7, color: decor),
                ),
              ],
              fitted(const Alignment(-1, -0.3), [
                Transform.rotate(
                  angle: -0.06,
                  child: _CalendarPage(
                    header: card.badge ?? '',
                    day: card.hero,
                    width: w * 0.5,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                // Angka sudah besar di sobekan kalender: tanpa hero di sini.
                texts[0],
                texts[2],
                ...texts.skip(3),
              ]),
            ),
            _Layout.photos => (
              [
                Positioned(
                  left: -w * 0.3,
                  top: h * 0.35,
                  child: _Blob(size: w * 0.6, color: decor),
                ),
              ],
              [
                const SizedBox(height: Spacing.lg),
                if (card.extra case final extra?)
                  Expanded(child: extra)
                else
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.photo_library_rounded,
                        size: w * 0.3,
                        color: ink.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                const SizedBox(height: Spacing.lg),
                ...texts,
              ],
            ),
            _Layout.closing => (
              [
                Positioned(
                  left: -w * 0.1,
                  right: -w * 0.1,
                  bottom: -w * 0.6,
                  child: _Blob(size: w * 1.2, color: decor),
                ),
              ],
              fitted(Alignment.center, [
                if (card.mascot case final mood?)
                  Mascot(size: w * 0.38, expression: mood),
                const SizedBox(height: Spacing.md),
                ...texts,
              ]),
            ),
          };
          return Stack(
            children: [
              ...decorations,
              Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: align,
                  children: [top, ...body],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Ikon besar di lingkaran latar dengan garis tebal.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surface,
        border: Border.all(
          color: scheme.onSurface,
          width: AppStyle.of(context).frameWidth,
        ),
      ),
      child: Icon(icon, size: size * 0.5, color: scheme.onSurface),
    );
  }
}

/// Sobekan kalender: strip hari di atas, angka tanggal besar.
class _CalendarPage extends StatelessWidget {
  const _CalendarPage({
    required this.header,
    required this.day,
    required this.width,
  });

  final String header;
  final String day;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final base = theme.textTheme.displayMedium!;
    return SizedBox(
      width: width,
      child: FrameCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: ink,
              padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
              alignment: Alignment.center,
              child: Text(
                header,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.surface,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Text(
                  day,
                  style: base.copyWith(
                    color: ink,
                    fontSize: (base.fontSize ?? 32) * 2.25,
                    height: 1.1,
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

/// Lingkaran dekor: isi warna atau cincin.
class _Blob extends StatelessWidget {
  const _Blob({required this.size, this.color, this.ring});

  final double size;
  final Color? color;
  final Color? ring;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: ring == null ? null : Border.all(color: ring!, width: 2),
    ),
  );
}

/// Label kapsul bergaris tebal ala stiker.
class _Sticker extends StatelessWidget {
  const _Sticker(this.text, {this.icon, this.color});

  final String text;
  final IconData? icon;

  /// Null = latar tema.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        border: Border.all(color: ink, width: AppStyle.of(context).frameWidth),
        borderRadius: BorderRadius.circular(Spacing.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: Spacing.lg, color: ink),
            const SizedBox(width: Spacing.xs),
          ],
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu terakhir: 5 kartu mini (2-2-1) bertumpuk tipis + tombol Selesai.
class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.month,
    required this.posters,
    required this.total,
    required this.onOpen,
  });

  final String month;
  final List<_Poster> posters;
  final int total;
  final ValueChanged<int> onOpen;

  // Miring tiap kartu mini (radian), selang-seling supaya tidak kaku.
  static const _tilt = [-0.05, 0.04, 0.03, -0.04, -0.02];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget mini(int i) => Transform.rotate(
      angle: _tilt[i],
      child: _MiniCard(poster: posters[i], onTap: () => onOpen(i)),
    );
    // Tumpang tipis: tiap baris naik sedikit menimpa baris di atasnya.
    Widget row(List<int> items) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final i in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
              child: mini(i),
            ),
          ),
      ],
    );
    return _Framed(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _Sticker('$total / $total'),
                const Spacer(),
                Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text('$month kamu', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => Center(
                  child: SizedBox(
                    height: min(box.maxHeight, box.maxWidth),
                    child: Column(
                      children: [
                        Expanded(child: row([0, 1])),
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -Spacing.xs),
                            child: row([2, 3]),
                          ),
                        ),
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -Spacing.sm),
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: mini(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.poster, required this.onTap});

  final _Poster poster;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    // Isi mengecil sendiri bila kartu pendek (layar kecil).
    Widget fit(Alignment align, Widget child) => Align(
      alignment: align,
      child: FittedBox(fit: BoxFit.scaleDown, alignment: align, child: child),
    );
    return Semantics(
      button: true,
      label: 'Buka kartu ${poster.summaryLabel}',
      child: FrameCard(
        color: poster.color,
        padding: const EdgeInsets.all(Spacing.sm),
        onTap: onTap,
        child: SizedBox.expand(
          child: Stack(
            children: [
              fit(
                Alignment.topLeft,
                Text(
                  poster.summaryLabel,
                  style: theme.textTheme.labelSmall?.copyWith(color: ink),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Icon(poster.icon, size: Spacing.lg, color: ink),
              ),
              fit(
                Alignment.bottomLeft,
                Text(
                  poster.summaryValue,
                  style: theme.textTheme.titleLarge?.copyWith(color: ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid 2x2 polaroid persegi yang menyesuaikan sisa tinggi kartu.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid(this.photos);

  final List<Attachment> photos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final side = min(box.maxWidth, box.maxHeight);
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: SizedBox.square(
          dimension: side,
          child: GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            mainAxisSpacing: Spacing.sm,
            crossAxisSpacing: Spacing.sm,
            children: [
              for (final (i, photo) in photos.indexed)
                // Bingkai polaroid, miring selang-seling.
                Transform.rotate(
                  angle: const [-0.05, 0.04, 0.03, -0.04][i],
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.xs),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      border: Border.all(
                        color: scheme.onSurface,
                        width: AppStyle.of(context).frameWidth,
                      ),
                    ),
                    child: AttachmentImage(id: photo.id, thumb: true),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Halaman ${active + 1} dari $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
              width: i == active ? Spacing.lg : Spacing.sm,
              height: Spacing.sm,
              decoration: BoxDecoration(
                color: i == active
                    ? scheme.onSurface
                    : scheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Spacing.xs),
              ),
            ),
        ],
      ),
    );
  }
}
