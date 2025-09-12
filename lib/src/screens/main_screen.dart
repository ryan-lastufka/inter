import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inter/src/features/ui_state_provider.dart';
import 'package:inter/src/widgets/detail_panel.dart';
import 'package:inter/src/widgets/edit_panel.dart';
import 'package:inter/src/widgets/nav_panel.dart';

const double mobileBreakpoint = 600;

const double tabletBreakpoint = 1200;

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(uiStateProvider);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Inter'),
        leading: LayoutBuilder(
          builder: (context, constraints) {
            if (MediaQuery.of(context).size.width < tabletBreakpoint) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                   if (MediaQuery.of(context).size.width < mobileBreakpoint) {
                     scaffoldKey.currentState?.openDrawer();
                   } else {
                     ref.read(uiStateProvider.notifier).toggleNavPanel();
                   }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (MediaQuery.of(context).size.width < tabletBreakpoint) {
                return IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  onPressed: () {
                     if (MediaQuery.of(context).size.width < mobileBreakpoint) {
                        scaffoldKey.currentState?.openEndDrawer();
                     } else {
                       ref.read(uiStateProvider.notifier).toggleDetailPanel();
                     }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      drawer: LayoutBuilder(
        builder: (context, constraints) {
           if (MediaQuery.of(context).size.width < mobileBreakpoint) {
             return const NavPanel();
           }
           return const SizedBox.shrink();
        }
      ),
      endDrawer: LayoutBuilder(
          builder: (context, constraints) {
           if (MediaQuery.of(context).size.width < mobileBreakpoint) {
             return const DetailPanel();
           }
           return const SizedBox.shrink();
        }
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileBreakpoint) {
            return const EditPanel();
          }
          else {
            return Row(
              children: [
                if (uiState.isNavPanelVisible)
                  const SizedBox(
                    width: 250,
                    child: NavPanel(),
                  ),
                const Expanded(
                  child: EditPanel(),
                ),
                if (uiState.isDetailPanelVisible)
                  const SizedBox(
                    width: 250,
                    child: DetailPanel(),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}
