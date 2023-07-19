import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:miru_app/pages/detail/controller.dart';
import 'package:miru_app/pages/detail/widgets/detail_appbar_flexible_space.dart';
import 'package:miru_app/pages/detail/widgets/detail_appbar_title.dart';
import 'package:miru_app/pages/detail/widgets/detail_background_color.dart';
import 'package:miru_app/pages/detail/widgets/detail_episodes.dart';
import 'package:miru_app/pages/detail/widgets/detail_favorite_button.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/cache_network_image.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key? key,
    required this.url,
    required this.package,
    this.heroTag,
  }) : super(key: key);
  final String url;
  final String package;
  final String? heroTag;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DetailPageController c;

  @override
  void initState() {
    c = Get.put(
      DetailPageController(
        package: widget.package,
        url: widget.url,
        heroTag: widget.heroTag,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<DetailPageController>();
    super.dispose();
  }

  Widget _buildAndroidDetail(BuildContext context) {
    if (!ExtensionUtils.extensions.containsKey(widget.package)) {
      return Scaffold(
        body: Center(
          child: Text(FlutterI18n.translate(
            context,
            'common.extension-missing',
            translationParams: {
              'package': widget.package,
            },
          )),
        ),
      );
    }
    return Scaffold(
      body: Obx(() {
        if (c.error.value.isNotEmpty) {
          return Center(
            child: Text(c.error.value),
          );
        }
        return DefaultTabController(
          length: 3,
          child: NestedScrollView(
            controller: c.scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  snap: false,
                  primary: true,
                  title: DetailAppbarTitle(
                    c.isLoading.value ? '' : c.data.value!.title,
                    controller: c.scrollController,
                  ),
                  flexibleSpace: const DetailAppbarflexibleSpace(),
                  bottom: TabBar(
                    tabs: [
                      Tab(text: 'detail.episodes'.i18n),
                      Tab(text: 'detail.overview'.i18n),
                      Tab(text: 'detail.cast'.i18n),
                    ],
                  ),
                  expandedHeight: 400,
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: TabBarView(
                children: [
                  const DetailEpisodes(),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        SelectableText(
                          c.isLoading.value ? '' : c.data.value!.desc ?? '',
                        ),
                      ],
                    ),
                  ),
                  const Center(
                    child: Text("敬请期待"),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDesktopDetail(BuildContext context) {
    if (!ExtensionUtils.extensions.containsKey(widget.package)) {
      return Center(
        child: Text(
          FlutterI18n.translate(
            context,
            'common.extension-missing',
            translationParams: {
              'package': widget.package,
            },
          ),
        ),
      );
    }
    return Obx(() {
      if (c.error.value.isNotEmpty) {
        return Center(
          child: Text(c.error.value),
        );
      }

      if (c.data.value == null) {
        return const Center(
          child: ProgressRing(),
        );
      }
      return Stack(
        children: [
          Animate(
            child: CacheNetWorkImage(
              c.data.value!.cover,
              width: double.infinity,
            ),
          ).blur(
            begin: const Offset(10, 10),
            end: const Offset(0, 0),
          ),
          Positioned.fill(
            child: DetailBackgroundColor(controller: c.scrollController),
          ),
          Positioned.fill(child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: c.scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 1200 ? 150 : 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 300),
                    SizedBox(
                      height: 330,
                      child: Row(
                        children: [
                          if (constraints.maxWidth > 600) ...[
                            Container(
                              width: 230,
                              height: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CacheNetWorkImage(
                                c.data.value!.cover,
                              ),
                            ),
                            const SizedBox(width: 30),
                          ],
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SelectableText(
                                c.data.value!.title,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 100,
                                ),
                                child: SelectableText(c.data.value!.desc!),
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  // 收藏按钮
                                  DetailFavoriteButton(),
                                  SizedBox(width: 8),
                                  // Button(
                                  //   child: const Padding(
                                  //     padding: EdgeInsets.only(
                                  //         left: 10,
                                  //         right: 10,
                                  //         top: 5,
                                  //         bottom: 5),
                                  //     child: Row(
                                  //       mainAxisSize: MainAxisSize.min,
                                  //       children: [
                                  //         Text("TMDB"),
                                  //         SizedBox(width: 8),
                                  //         Icon(FluentIcons.pop_expand)
                                  //       ],
                                  //     ),
                                  //   ),
                                  //   onPressed: () {},
                                  // ),
                                ],
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (c.data.value!.episodes != null) const DetailEpisodes(),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroidDetail,
      desktopBuilder: _buildDesktopDetail,
    );
  }
}
