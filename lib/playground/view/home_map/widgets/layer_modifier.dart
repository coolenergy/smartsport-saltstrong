import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelsV2/layer_wrapper.dart';
import '../controller/layer_controller.dart';
import '../controller/layer_state.dart';

class LayerModifier extends ConsumerWidget {
  Future<T?> show<T>(BuildContext context) {
    return showModalBottomSheet(
        constraints: const BoxConstraints(maxWidth: 600),
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        context: context,
        useRootNavigator: false,
        builder: (context) => const LayerModifier());
  }

  const LayerModifier({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(saltStrongLayerControllerProvider);
    final SaltMapLayerController controller = ref.read(saltStrongLayerControllerProvider.notifier);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9, maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CloseButton(),
          Flexible(
            child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  return ListTile(
                      key: ValueKey(state.layers[index].name),
                      title: Text(state.layers[index].name),
                      trailing: CustomReorderableDelayedDragStartListener(
                        index: index,
                        child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.drag_handle)),
                      ),
                      subtitle: Container(alignment: Alignment.centerLeft, child: buildControl(state, index, controller, context)));
                },
                itemCount: state.layers.length,
                onReorder: (int oldIndex, int newIndex) {
                  controller.swapLayers(oldIndex, newIndex);
                }),
          ),
          const SizedBox(
            height: 24,
          )
        ],
      ),
    );
  }

  Widget buildControl(SaltMapState state, int index, SaltMapLayerController controller, context) {
    final item = state.layers[index];
    switch (item.layerType) {
      case LayerType.tile:
        return Slider(
          value: state.layers[index].opacity,
          onChangeEnd: (value) {
            controller.updateLayerOpacity(item, value);
          },
          onChanged: (value) {
            controller.updateLayerOpacity(item, value);
          },
        );

      case LayerType.marker:
      case LayerType.poly:
        return Switch(
          value: state.layers[index].opacity == 1,
          onChanged: (value) {
            controller.updateLayerOpacity(state.layers[index], value ? 1 : 0);
          },
        );
    }
  }
}

void showLoadingDialog(context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ));
}

class CustomReorderableDelayedDragStartListener extends ReorderableDragStartListener {
  const CustomReorderableDelayedDragStartListener({
    Key? key,
    required Widget child,
    required int index,
    bool enabled = true,
  }) : super(key: key, child: child, index: index, enabled: enabled);

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(delay: const Duration(milliseconds: 1), debugOwner: this);
  }
}
