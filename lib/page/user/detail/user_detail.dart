/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:pixez/component/selectable_html.dart';
import 'package:pixez/i18n.dart';
import 'package:pixez/models/user_detail.dart';
import 'package:pixez/page/follow/follow_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserDetailPage extends StatefulWidget {
  final UserDetail? userDetail;
  final bool isNewNested;
  final bool? isNovel;

  UserDetailPage(
      {Key? key,
      required this.userDetail,
      this.isNewNested = false,
      this.isNovel})
      : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  String _displaySocialLabel({
    required String? account,
    required String? url,
  }) {
    if (account != null && account.isNotEmpty) return account;
    if (url != null && url.isNotEmpty) return url;
    return "";
  }

  bool _isNovel = false;
  bool _isNewNested = false;

  @override
  void initState() {
    _isNewNested = widget.isNewNested;
    _isNovel = widget.isNovel ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var detail = widget.userDetail;
    var profile = widget.userDetail?.profile;
    var public = widget.userDetail?.profile_publicity;
    if (_isNewNested)
      return SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Builder(builder: (context) {
            return _buildScrollView(context, detail, profile, public);
          }),
        ),
      );
    return _buildScrollView(context, detail, profile, public);
  }

  CustomScrollView _buildScrollView(BuildContext context, UserDetail? detail,
      Profile? profile, Profile_publicity? public) {
    return CustomScrollView(
      key: PageStorageKey<String>("user_detail"),
      slivers: [
        if (_isNewNested)
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SelectionArea(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.userDetail?.user.comment != null &&
                            widget.userDetail?.user.comment!.isNotEmpty == true
                        ? SelectableHtml(data: widget.userDetail!.user.comment!)
                        : SelectableHtml(
                            data: '~',
                          )),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DataTable(
              columns: <DataColumn>[
                DataColumn(label: Text(I18n.of(context).nickname)),
                DataColumn(
                    label: Expanded(child: Text(detail?.user.name ?? ""))),
              ],
              rows: <DataRow>[
                DataRow(cells: [
                  DataCell(Text(I18n.of(context).painter_id)),
                  DataCell(Text(detail?.user.id.toString() ?? ""), onTap: () {
                    try {
                      Clipboard.setData(
                          ClipboardData(text: detail!.user.id.toString()));
                    } catch (e) {}
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text(I18n.of(context).total_follow_users)),
                  DataCell(
                      Text(detail?.profile.total_follow_users.toString() ?? ""),
                      onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text(I18n.of(context).followed),
                        ),
                        body: detail == null
                            ? Container()
                            : FollowList(id: detail.user.id, isNovel: _isNovel),
                      );
                    }));
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text(I18n.of(context).total_mypixiv_users)),
                  DataCell(
                      Text(
                          detail?.profile.total_mypixiv_users.toString() ?? ""),
                      onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: detail == null
                            ? Container()
                            : FollowList(
                                id: detail.user.id,
                                isFollowMe: true,
                              ),
                      );
                    }));
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text(I18n.of(context).twitter_account)),
                  DataCell(
                      Text(_displaySocialLabel(
                          account: profile?.twitter_account,
                          url: profile?.twitter_url)),
                      onTap: () async {
                    final url = profile?.twitter_url;
                    if (url != null) {
                      try {
                        if (Platform.isIOS) {
                          await launchUrlString(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrlString(url);
                        }
                      } catch (e) {
                        SharePlus.instance.share(ShareParams(text: url));
                      }
                    }
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text('Webpage')),
                  DataCell(
                    Text(profile?.webpage ?? ""),
                    onTap: () async {
                      final url = profile?.webpage;
                      if (url == null || url.isEmpty) return;
                      try {
                        if (Platform.isIOS) {
                          await launchUrlString(url,
                              mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrlString(url);
                        }
                      } catch (e) {
                        SharePlus.instance.share(ShareParams(text: url));
                      }
                    },
                  ),
                ]),
                DataRow(cells: [
                  DataCell(Text('Birthday')),
                  DataCell(Text(detail?.profile.birth_day ?? detail?.profile.birth ?? "")),
                ]),
                DataRow(cells: [
                  DataCell(Text(I18n.of(context).gender)),
                  DataCell(Text(detail?.profile.gender ?? "")),
                ]),
                DataRow(cells: [
                  DataCell(Text(I18n.of(context).job)),
                  DataCell(Text(detail?.profile.job ?? "")),
                ]),
                DataRow(cells: [
                  DataCell(Text('Pawoo')),
                  DataCell(Text((detail?.profile.pawoo_url?.isNotEmpty ?? false) ? 'Link' : 'none'),
                      onTap: () async {
                    var url = detail?.profile.pawoo_url;
                    if (url == null || url.isEmpty) return;
                    try {
                      await launchUrlString(url);
                    } catch (e) {}
                  }),
                ]),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 200,
          ),
        )
      ],
    );
  }
}
