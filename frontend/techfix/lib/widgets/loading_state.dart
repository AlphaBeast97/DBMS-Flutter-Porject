import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class SkeletonCard extends StatefulWidget {
  final int lines;
  const SkeletonCard({super.key, this.lines = 2});
  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        final dx = _shimmer.value;
        final shimmerGradient = LinearGradient(
          begin: Alignment(-1.0 + dx * 2.5, 0),
          end: Alignment(1.0 + dx * 2.5, 0),
          colors: [Colors.transparent, Colors.white.withOpacity(0.45), Colors.transparent],
          stops: const [0.0, 0.4, 1.0],
        );
        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 0.55 * MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(widget.lines, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Container(
                      height: 11,
                      width: i == widget.lines - 1 ? 0.7 * MediaQuery.of(context).size.width : double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                    ),
                  )),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 18, width: 70, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
                      Container(height: 18, width: 50, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(100))),
                    ],
                  ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(child: Container(decoration: BoxDecoration(gradient: shimmerGradient))),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LoadingState extends StatelessWidget {
  final int count;
  const LoadingState({super.key, this.count = 3});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(count, (i) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SkeletonCard(),
        )),
      ),
    );
  }
}
