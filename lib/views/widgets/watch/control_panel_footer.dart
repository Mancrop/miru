import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/controllers/watch/reader_controller.dart';
import 'package:miru_app/views/widgets/button.dart';

class ControlPanelFooter<T extends ReaderController> extends StatelessWidget {
  const ControlPanelFooter(this.tag, {super.key});
  final String tag;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<T>(tag: tag);
    double screenWidth = MediaQuery.of(context).size.width;
    double space = screenWidth / 300;
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(255),
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                PlatformIconButton(
                  icon: Icon(Icons.arrow_back, size: 23),
                  onPressed: c.index.value > 0
                      ? () {
                          c.index.value--;
                        }
                      : null,
                ),
                SizedBox(width: space),
                PlatformIconButton(
                  icon: Icon(Icons.menu, size: 23),
                ),
                SizedBox(width: space),
                PlatformIconButton(icon: Icon(Icons.settings, size: 23)),
                SizedBox(width: space),
              ],
            ),
            PlatformIconButton(
              icon: Icon(Icons.arrow_forward, size: 23),
              onPressed: c.index.value != c.playList.length - 1
                  ? () {
                      c.index.value++;
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
