import 'package:flutter/material.dart';

import '../tokens/breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (Breakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final Widget Function(T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    T value;
    if (Breakpoints.isDesktop(context)) {
      value = desktop ?? tablet ?? mobile;
    } else if (Breakpoints.isTablet(context)) {
      value = tablet ?? mobile;
    } else {
      value = mobile;
    }
    return builder(value);
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double mobileBreakpoint;
  final double tabletBreakpoint;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.childAspectRatio,
  });

  int _columnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) {
      return desktopColumns ?? 3;
    }
    if (width >= mobileBreakpoint) {
      return tabletColumns ?? 2;
    }
    return mobileColumns ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columnCount(context);

    if (columns == 1) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: runSpacing),
          ],
        ],
      );
    }

    final rows = (children.length / columns).ceil();
    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columns;
        final rowChildren = <Widget>[];
        for (int colIndex = 0; colIndex < columns; colIndex++) {
          final itemIndex = startIndex + colIndex;
          if (itemIndex < children.length) {
            rowChildren.add(Expanded(child: children[itemIndex]));
          } else {
            rowChildren.add(const Expanded(child: SizedBox.shrink()));
          }
          if (colIndex < columns - 1) {
            rowChildren.add(SizedBox(width: spacing));
          }
        }
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex < rows - 1 ? runSpacing : 0,
          ),
          child: Row(children: rowChildren),
        );
      }),
    );
  }
}
