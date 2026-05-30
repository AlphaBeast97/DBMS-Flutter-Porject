import 'package:flutter/material.dart';
import 'package:techfix/theme/app_theme.dart';

class SkeletonCard extends StatelessWidget {
  final int lines;

  const SkeletonCard({super.key, this.lines = 2});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 0.55 * MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(lines, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              height: 11,
              width: i == lines - 1 ? 0.7 * MediaQuery.of(context).size.width : double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          )),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 18,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              Container(
                height: 18,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  final int count;

  const LoadingState({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: SkeletonCard(),
      )),
    );
  }
}
