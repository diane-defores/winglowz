import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    required this.child,
    this.padding = AppInsets.card,
    this.stretch = true,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || subtitle != null || leading != null;
    final header = hasHeader
        ? _AppSectionHeader(title: title, subtitle: subtitle, leading: leading)
        : null;

    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: stretch
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: [
            if (header != null) ...[header, AppGaps.x3],
            child,
          ],
        ),
      ),
    );
  }
}

class _AppSectionHeader extends StatelessWidget {
  const _AppSectionHeader({this.title, this.subtitle, this.leading});

  final String? title;
  final String? subtitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(title!, style: Theme.of(context).textTheme.titleSmall),
        if (subtitle != null) ...[
          AppGaps.x1,
          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );

    if (leading == null) {
      return textColumn;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading!,
        AppGaps.horizontalX3,
        Expanded(child: textColumn),
      ],
    );
  }
}

class AppFormActions extends StatelessWidget {
  const AppFormActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryIcon = Icons.add,
    this.secondaryLabel = 'Refresh',
    this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final IconData primaryIcon;
  final String secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onPrimary,
            icon: Icon(primaryIcon),
            label: Text(primaryLabel),
          ),
        ),
        if (onSecondary != null) ...[
          AppGaps.horizontalX2,
          OutlinedButton(onPressed: onSecondary, child: Text(secondaryLabel)),
        ],
      ],
    );
  }
}

class AppEntityListHeader extends StatelessWidget {
  const AppEntityListHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleSmall);
  }
}

class AppEmptyStateCard extends StatelessWidget {
  const AppEmptyStateCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(message)));
  }
}

class AppEntityListTile extends StatelessWidget {
  const AppEntityListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.isThreeLine = false,
    this.actions = const [],
  });

  final Widget title;
  final Widget? subtitle;
  final bool isThreeLine;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: title,
        subtitle: subtitle,
        isThreeLine: isThreeLine,
        trailing: actions.isEmpty
            ? null
            : Wrap(
                spacing: AppIconMetrics.listActionSpacing,
                children: actions,
              ),
      ),
    );
  }
}

class AppStatusCard extends StatelessWidget {
  const AppStatusCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
