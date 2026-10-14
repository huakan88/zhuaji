import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_fonts.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../domain/scale/scale_parser.dart';
import '../../services/scale_service.dart';
import '../../state/app_controller.dart';

enum _Step { checking, owner, together, done, failed }

/// 「抱猫称」: weigh yourself, weigh yourself holding the cat, keep the
/// difference. Pops with the cat's kg, or null for manual entry.
class ScalePage extends StatefulWidget {
  const ScalePage({required this.source, super.key});

  final ScaleSource source;

  static const quietFor = Duration(seconds: 90);

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  var _step = _Step.checking;
  String _problem = '';
  ScaleReading? _live;
  double? _owner;
  double? _cat;
  String? _hint;
  StreamSubscription<ScaleReading>? _sub;
  Timer? _quiet;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    _quiet?.cancel();
    _sub?.cancel();
    widget.source.stop();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _step = _Step.checking;
      _live = null;
      _hint = null;
    });
    final status = await widget.source.prepare();
    if (!mounted) return;
    if (status != ScaleStatus.ready) {
      _fail(switch (status) {
        ScaleStatus.unsupported => '这台手机不支持蓝牙秤',
        ScaleStatus.denied => '没有蓝牙权限，可以在系统设置里打开',
        _ =>
          defaultTargetPlatform == TargetPlatform.iOS
              ? '请先在控制中心打开蓝牙，再回来重试'
              : '蓝牙没打开',
      });
      return;
    }
    await _sub?.cancel();
    _sub = widget.source.readings().listen(
      _onReading,
      onError: (Object _) => _fail('连不上秤，可以重试或手动输入'),
    );
    _arm();
    setState(() => _step = _owner == null ? _Step.owner : _Step.together);
  }

  void _arm() {
    _quiet?.cancel();
    _quiet = Timer(ScalePage.quietFor, () {
      if (_step == _Step.owner || _step == _Step.together) {
        _fail('没收到秤的数据。踩一下秤把它叫醒，再点重试');
      }
    });
  }

  void _fail(String text) {
    _quiet?.cancel();
    _sub?.cancel();
    _sub = null;
    widget.source.stop();
    if (!mounted) return;
    setState(() {
      _step = _Step.failed;
      _problem = text;
    });
  }

  void _onReading(ScaleReading reading) {
    if (!mounted) return;
    _arm();
    setState(() => _live = reading);
    if (!reading.stable) return;
    if (_step == _Step.owner) {
      if (reading.kg < 2) return;
      _setOwner(reading.kg);
      return;
    }
    if (_step != _Step.together) return;
    final owner = _owner!;
    if (reading.kg < owner + minCatKg) {
      setState(() => _hint = '还是自己的重量，抱上猫再站上去');
      return;
    }
    final cat = catWeightFrom(togetherKg: reading.kg, ownerKg: owner);
    if (cat == null) {
      setState(
        () => _hint =
            '差了 ${(reading.kg - owner).toStringAsFixed(1)} kg，不像一只猫。'
            '自己的重量可能不对，点「重称自己」',
      );
      return;
    }
    _quiet?.cancel();
    setState(() {
      _cat = cat;
      _step = _Step.done;
    });
  }

  Future<void> _setOwner(double kg) async {
    final app = AppScope.of<AppController>(context);
    setState(() {
      _owner = kg;
      _hint = null;
      _step = _Step.together;
    });
    await app.saveOwnerWeight(kg);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of<AppController>(context);
    final cat = app.active;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: zhuajiBar('蓝牙秤'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          Text(
            '抱猫称：先称自己，再抱着${cat?.name ?? '猫'}称，差就是猫的体重。',
            style: zhuaji.copyWith(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          _Steps(step: _step, owner: _owner),
          const SizedBox(height: 16),
          QuietCard(child: _body(app)),
          if (_hint != null) ...[
            const SizedBox(height: 12),
            Text(
              _hint!,
              style: zhuaji.copyWith(fontSize: 13, color: AppColors.coralDeep),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '支持小米体脂秤 2 和标准蓝牙体重秤。只用蓝牙读秤上的数字，不定位、不上传。'
            '这是新功能，还没在真秤上试过；读数不对就点「手动输入」。',
            style: zhuaji.copyWith(
              fontSize: 12,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push('/privacy'),
              child: const Text('隐私政策'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _step == _Step.done
              ? FilledButton(
                  onPressed: () => context.pop(_cat),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('用这个'),
                )
              : OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('手动输入'),
                ),
        ),
      ),
    );
  }

  Widget _body(AppController app) {
    switch (_step) {
      case _Step.checking:
        return const _Center(busy: true, title: '正在打开蓝牙', body: '第一次用会问蓝牙权限');
      case _Step.failed:
        return Column(
          children: [
            _Center(
              icon: Icons.bluetooth_disabled,
              title: '没连上秤',
              body: _problem,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _connect, child: const Text('重试')),
          ],
        );
      case _Step.owner:
        final last = app.ownerWeightKg;
        return Column(
          children: [
            _Live(reading: _live, label: '先自己站上去'),
            if (last != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _setOwner(last),
                child: Text('自己还是 ${last.toStringAsFixed(2)} kg'),
              ),
            ],
          ],
        );
      case _Step.together:
        return Column(
          children: [
            _Live(reading: _live, label: '抱着猫站上去'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '自己 ${_owner!.toStringAsFixed(2)} kg',
                    style: zhuaji.copyWith(color: AppColors.muted),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _owner = null;
                    _hint = null;
                    _step = _Step.owner;
                  }),
                  child: const Text('重称自己'),
                ),
              ],
            ),
          ],
        );
      case _Step.done:
        return Column(
          children: [
            Text(
              '${_cat!.toStringAsFixed(2)} kg',
              style: zhuaji.copyWith(fontSize: 44, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '抱猫 ${(_owner! + _cat!).toStringAsFixed(2)} - 自己 ${_owner!.toStringAsFixed(2)}',
              style: zhuaji.copyWith(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() {
                _cat = null;
                _hint = null;
                _step = _Step.together;
              }),
              child: const Text('再称一次'),
            ),
          ],
        );
    }
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.step, required this.owner});

  final _Step step;
  final double? owner;

  @override
  Widget build(BuildContext context) {
    final first = owner != null;
    final second = step == _Step.done;
    return Row(
      children: [
        Expanded(
          child: _Dot(index: 1, label: '称自己', done: first),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Dot(index: 2, label: '抱猫称', done: second),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.label, required this.done});

  final int index;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: done ? AppColors.tintCoral : AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: done ? AppColors.coralDeep : AppColors.line),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: done ? AppColors.coralDeep : AppColors.muted,
          ),
          const SizedBox(width: 6),
          Text(
            '$index $label',
            style: zhuaji.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Live extends StatelessWidget {
  const _Live({required this.reading, required this.label});

  final ScaleReading? reading;
  final String label;

  @override
  Widget build(BuildContext context) {
    final value = reading;
    return Column(
      children: [
        Text(label, style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          value == null ? '--.-- kg' : '${value.kg.toStringAsFixed(2)} kg',
          style: zhuaji.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: value == null ? AppColors.line : AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value == null
              ? '踩一下秤把它叫醒'
              : value.stable
              ? '稳了'
              : '站稳别动，数字不跳了就自动记下',
          style: zhuaji.copyWith(fontSize: 13, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Center extends StatelessWidget {
  const _Center({
    required this.title,
    required this.body,
    this.icon,
    this.busy = false,
  });

  final String title;
  final String body;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          if (busy)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else if (icon != null)
            Icon(icon, size: 32, color: AppColors.coralDeep),
          const SizedBox(height: 12),
          Text(title, style: zhuaji.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: zhuaji.copyWith(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
