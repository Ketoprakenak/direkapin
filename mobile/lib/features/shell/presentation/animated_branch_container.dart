import 'package:flutter/widgets.dart';

import '../../../core/theme/tokens.dart';

// Lebih panjang dari Motion.duration (200 ms): geser satu layar penuh perlu waktu lebih.
const _tabDuration = Duration(milliseconds: 250);

/// Geser horizontal sebagai fraksi lebar layar.
const _tabSlide = 0.15;

/// Isi tab bawah: geser + fade sesuai arah index, semua cabang tetap terpasang
/// supaya state dan posisi scroll tiap tab terjaga.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: _tabDuration,
    value: 1,
  )..addStatusListener(_onStatus);
  late final _progress = CurvedAnimation(
    parent: _controller,
    curve: Motion.curve,
  );

  /// Cabang yang sedang keluar; null bila tidak ada animasi.
  int? _previous;

  /// 1 = ke tab kanan (konten bergeser ke kiri), -1 = ke tab kiri.
  double _direction = 1;

  /// Posisi & opasitas awal cabang keluar: kondisi saat itu bila ditap
  /// di tengah animasi, supaya tidak melompat.
  Offset _outStart = Offset.zero;
  double _outOpacity = 1;

  void _onStatus(AnimationStatus status) {
    if (status.isCompleted && _previous != null) {
      setState(() => _previous = null);
    }
  }

  @override
  void didUpdateWidget(AnimatedBranchContainer old) {
    super.didUpdateWidget(old);
    final from = old.currentIndex;
    final to = widget.currentIndex;
    if (from == to) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _controller.value = 1;
      return;
    }
    // Tap saat animasi berjalan: tab yang sedang masuk jadi tab yang keluar
    // mulai dari posisinya sekarang; tab keluar sebelumnya langsung disembunyikan.
    final p = _controller.isAnimating ? _progress.value : 1.0;
    _outStart = Offset(_direction * _tabSlide * (1 - p), 0);
    _outOpacity = p;
    _previous = from;
    _direction = (to - from).sign.toDouble();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incoming = Tween(
      begin: Offset(_direction * _tabSlide, 0),
      end: Offset.zero,
    ).animate(_progress);
    final outgoing = Tween(
      begin: _outStart,
      end: Offset(-_direction * _tabSlide, 0),
    ).animate(_progress);
    final fadeOut = Tween(begin: _outOpacity, end: 0.0).animate(_progress);

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _branch(
            i,
            active: i == widget.currentIndex,
            leaving: i == _previous,
            position: i == widget.currentIndex
                ? incoming
                : i == _previous
                ? outgoing
                : null,
            opacity: i == widget.currentIndex
                ? _progress
                : i == _previous
                ? fadeOut
                : null,
          ),
      ],
    );
  }

  // Struktur widget sama untuk tiap cabang agar navigatornya tidak dibangun ulang.
  Widget _branch(
    int index, {
    required bool active,
    required bool leaving,
    required Animation<Offset>? position,
    required Animation<double>? opacity,
  }) {
    final visible = active || leaving;
    return Offstage(
      key: ValueKey(index),
      offstage: !visible,
      child: TickerMode(
        enabled: visible,
        child: IgnorePointer(
          ignoring: !active,
          // Seperti IndexedStack: fokus/keyboard tidak tertinggal di tab lain.
          child: ExcludeFocus(
            excluding: !active,
            child: FadeTransition(
              opacity: opacity ?? kAlwaysCompleteAnimation,
              child: SlideTransition(
                position: position ?? const AlwaysStoppedAnimation(Offset.zero),
                child: widget.children[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
