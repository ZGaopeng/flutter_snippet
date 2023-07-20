/// 解约按钮放到 标题栏 右上角 更多菜单栏中
class NcOrderDetailTitleRescind extends StatefulWidget {
  final BuildContext buildContext;

  NcOrderDetailTitleRescind(this.buildContext);

  @override
  State<NcOrderDetailTitleRescind> createState() =>
      _NcOrderDetailTitleRescindState();
}

class _NcOrderDetailTitleRescindState extends State<NcOrderDetailTitleRescind> {
  // final TextEditingController _reasonController = TextEditingController();

  // bool _isShowNotice = true;

  @override
  Widget build(BuildContext mContext) {
    return Consumer(
        builder: (BuildContext context, NCOrderDetailProvider provider, ___) {
      var entity = provider.ncOrderDetailEntity;

      /// 是否显示解约按钮
      var canRescind = entity.canRescind == true;

      /// 是否显示尾款调价按钮
      var canAdjustDealEndPrice = entity.canAdjustDealEndPrice == true;

      /// 是否显示部分扣款按钮
      var canDeductPrice = entity.canDeductPrice == true;

      /// 是否显示补充资料按钮
      var canSupplementInfoBtn = entity.canSupplementInfoBtn == true;

      /// 是否显示修改卖家信息
      var canModifyOwnerInfo = entity.canModifyOwnerInfo == true;

      /// 是否显示转购销合同
      var canConvertPurchase = entity.canConvertPurchase == true;

      /// 是否显示建议买手批零按钮
      var wholesaleRetailButton = entity.wholesaleRetailButton == true;

      /// 是否显示修改收款账户按钮
      var canModifyAccount = entity.canModifyAccount == true;

      if (!canRescind &&
          !canAdjustDealEndPrice &&
          !canDeductPrice &&
          !canSupplementInfoBtn &&
          !wholesaleRetailButton &&
          !canConvertPurchase &&
          !canModifyAccount &&
          !canModifyOwnerInfo) {
        return Container();
      }
      return Center(
          child: PopupMenuButton(
        icon: Row(
          children: [
            Container(child: Text('操作')),
            Icon(
              Icons.more_vert,
              size: 18,
            )
          ],
        ),
        padding: EdgeInsets.only(right: 0),
        position: PopupMenuPosition.under,
        itemBuilder: (BuildContext context) => _menuItems(
          canRescind,
          canAdjustDealEndPrice,
          canDeductPrice,
          canSupplementInfoBtn,
          wholesaleRetailButton,
          canConvertPurchase,
          canModifyAccount,
          canModifyOwnerInfo,
        ),
        onSelected: (String action) {
          switch (action) {
            case 'rescind':
              _rescind(widget.buildContext, provider);
              break;
            case 'modifyPrice':
              _supplement(
                  context,
                  provider.ncOrderDetailEntity.ncOrderId.toString(),
                  entity.signType,
                  entity.contractInfo?.contractNumber);
              break;
            case 'deductPrice':
              _deductPriceAction(provider, entity.signType);
              break;
            case 'supplementaryInfo':
              _supplementInfoAction(provider);
              break;
            case 'convertPurchase':
              _convertPurchaseAction(provider);
              break;
            case 'wholesaleRetail':
              _buyerSuggestAction(provider);
              break;
            case 'canModifyAccount':
              pushChangeBankCardPage(provider);
              break;
            case 'modifyOwnerInfo':
              _modSellerInfo(provider);
              break;
          }
        },
        onCanceled: () {
          Log.d('onCanceled');
        },
      ));
    });
  }

  List<PopupMenuItem<String>> _menuItems(
    bool canRescind,
    bool canAdjustDealEndPrice,
    bool canDeductPrice,
    bool canSupplementInfoBtn,
    bool wholesaleRetailButton,
    bool canConvertPurchase,
    bool canModifyAccount,
    bool canModifyOwnerInfo,
  ) {
    var list = <PopupMenuItem<String>>[];
    if (canRescind) {
      list.add(PopupMenuItem<String>(
        value: 'rescind',
        child: Text('解约'),
      ));
    }
    if (canAdjustDealEndPrice) {
      list.add(PopupMenuItem<String>(
        value: 'modifyPrice',
        child: Text('尾款调价'),
      ));
    }
    if (canDeductPrice) {
      list.add(PopupMenuItem<String>(
        value: '',
        child: Text('部分扣款'),
      ));
    }
    if (canSupplementInfoBtn) {
      list.add(PopupMenuItem<String>(
        value: '',
        child: Text('修改图片信息'),
      ));
    }

    if (canModifyOwnerInfo) {
      list.add(PopupMenuItem<String>(
        value: '',
        child: Text('修改卖家信息'),
      ));
    }

    if (canConvertPurchase) {
      list.add(PopupMenuItem<String>(
        value: '',
        child: Text('转购销合同'),
      ));
    }

    if (wholesaleRetailButton) {
      list.add(PopupMenuItem<String>(
        value: '',
        child: Text('修改买手批零'),
      ));
    }

    if (canModifyAccount) {
      list.add(PopupMenuItem<String>(
        value: 'canModifyAccount',
        child: Text('修改收款账户'),
      ));
    }

    return list;
  }

  //NC 解约功能
  Future<void> _rescind(
      BuildContext ctx, NCOrderDetailProvider provider) async {
    var entity = provider.ncOrderDetailEntity;
    var ncOrderId = provider.ncOrderId.toString();
    // 已支付意向金，但是未支付保证金，发起解约时应该强提醒：
    // 标题：确认解约收车合同？内容：已发送保证金的支付申请，确认解约之后将取消支付申请，无法继续收车，若需要继续收车仍需解约完成！
    // 其他状态下弹框：是否解除收车合同
    var msg = '';
    if (entity?.refundRemind == true) {
      msg = '已发送支付申请，确认解约之后将取消支付申请，无法继续收车，若需要继续收车仍需解约完成！';
    }

    await showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return ThemeDialog(
            content: '是否解除收车合同',
            subContent: msg,
            negativeFun: (BuildContext context) async {
              Navigator.of(context).pop();
            },
            positiveFun: (BuildContext context) async {
              Navigator.of(context).pop();
              //handleResult(ctx,await router.navigateTo(ctx, pathNCOrderRefundInfoFun(ncOrderId ?? '')));
              await Rrc58RouterBridge.navigateTo(ctx,
                  routeName: RouteNames.pathNCOrderRefundInfo, params: {});
              handleResult(ctx, ResultInfo());
              ;
            },
          );
        });
  }

  /// NC尾款调价
  // void _modifyPrice(BuildContext ctx) {
  //   showDialog(
  //       context: ctx,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(builder: (BuildContext statefulContext,
  //             void Function(void Function()) setState) {
  //           return Dialog(
  //             child: Container(
  //               padding: EdgeInsets.only(
  //                 top: 21,
  //                 left: 20,
  //                 right: 20,
  //               ),
  //               height: 205,
  //               decoration:
  //                   BoxDecoration(borderRadius: BorderRadius.circular(8)),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Text(
  //                         '*',
  //                         style: TextStyle(
  //                             fontSize: 16,
  //                             color: Color(0xFFE13C3C),
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                       Text(
  //                         '尾款调价原因',
  //                         style: TextStyle(
  //                             fontSize: 16,
  //                             color: Color(0xFF1B1C24),
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 9),
  //                   Container(
  //                     height: 66,
  //                     padding: EdgeInsets.only(left: 0.0, right: 0.0),
  //                     decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.all(
  //                           Radius.circular(4.0),
  //                         ),
  //                         border: Border.all(color: Color(0xFFE9EAED)),
  //                         color: Colors.white),
  //                     child: Material(
  //                       child: TextField(
  //                         controller: _reasonController,
  //                         // maxLength: 100,
  //                         style: RrcTextStyles.textNormal16,
  //                         cursorColor: RrcColors.themeColor,
  //                         maxLines: 3,
  //                         decoration: InputDecoration(
  //                             fillColor: Colors.white,
  //                             filled: true,
  //                             border: InputBorder.none,
  //                             hintText: '请输入调价原因',
  //                             hintStyle: TextStyle(
  //                                 fontSize: RrcDimens.fontSp14,
  //                                 color: RrcColors.nc_make_price_tip_text,
  //                                 textBaseline: TextBaseline.alphabetic)),
  //                         onChanged: (value) {
  //                           _isShowNotice = ObjectUtil.isEmptyString(value);
  //                           setState(() {});
  //                         },
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(height: 3),
  //                   Text(
  //                     _isShowNotice ? '请输入原因！' : '',
  //                     style: TextStyle(fontSize: 12, color: Color(0xFFE62424)),
  //                   ),
  //                   SizedBox(height: 11),
  //                   Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Expanded(
  //                           child: GestureDetector(
  //                             onTap: () {
  //                               NavigatorUtil.pop(ctx);
  //                             },
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               height: 36.0,
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.all(
  //                                   Radius.circular(4.0),
  //                                 ),
  //                                 border: Border.all(
  //                                     color: RrcColors.themeColor, width: 1),
  //                               ),
  //                               child: Text(
  //                                 '取消',
  //                                 style: TextStyle(
  //                                     fontSize: 14,
  //                                     color: RrcColors.themeColor),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(width: 17),
  //                         Expanded(
  //                           child: GestureDetector(
  //                             onTap: () async {
  //                               await _supplement(context, '');
  //                             },
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               height: 36.0,
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.all(
  //                                   Radius.circular(4.0),
  //                                 ),
  //                                 gradient: const LinearGradient(colors: [
  //                                   Color(0xffFF791F),
  //                                   Color(0xffFF501C),
  //                                 ]),
  //                               ),
  //                               child: Text(
  //                                 '签署补充协议',
  //                                 style: TextStyle(
  //                                     fontSize: 14, color: Colors.white),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ])
  //                 ],
  //               ),
  //             ),
  //           );
  //         });
  //       });
  // }

  /// 签署补充协议
  Future<void> _supplement(BuildContext ctx, String ncOrderId, int? signType,
      String? contractNum) async {
    if (signType == 1) {
      await Rrc58RouterBridge.navigateTo(
        ctx,
        routeName: RouteNames.pathNCContractAdditional,
        params: {
          'orderId': ncOrderId,
          'modifyPrice': '1',
        },
      );
    } else if (signType == 2) {
      // 线下签约
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CommonWebViewPage(
            '',
            displayAppBar: false,
          ),
        ),
      );
    }
  }

  /// 部分扣款
  void _deductPriceAction(NCOrderDetailProvider provider, int? signType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (con) => NcOrderDeductPriceRefundInfoPage(
          ncOrderId: provider.ncOrderDetailEntity.ncOrderId.toString(),
          pageStatus: PageStatus.Sign,
          signType: signType,
        ),
      ),
    );
  }

  /// 补充资料
  void _supplementInfoAction(NCOrderDetailProvider provider) async {
    await Rrc58RouterBridge.navigateTo(context,
        routeName: RouteNames.pathNcOrderSupplementaryInfoPage,
        params: {
          'ncOrderId': provider.ncOrderDetailEntity.ncOrderId.toString()
        });
  }

  /// 修改卖家信息
  Future<void> _modSellerInfo(NCOrderDetailProvider provider) async {
    var params = {
      'url': '',
    };
    HandleH5ThemeUtil.handleThemeColor(RouteNames.pathH5, params);
    await Rrc58RouterBridge.navigateTo(context,
        routeName: RouteNames.pathH5, params: params);
  }

  /// 建议买手批零
  void _buyerSuggestAction(NCOrderDetailProvider provider) async {
    ///点击查看批零状态
    var statusResponse = await Request.instance
        .getWholesaleRetailStatus(ncOrderId: provider.ncOrderId);
    if (statusResponse.isSuccess() && statusResponse.data == true) {
      await NCEditBuyerSuggest.show(
        ncOrderId: provider.ncOrderId,
        selectTitle: provider.ncOrderDetailEntity.wholesaleRetail,
        successBackCall: ({required state}) {
          provider.ncOrderDetailEntity.wholesaleRetail = state;

          ///必须要进行深拷贝，完成对象的改变，才能进行刷新响应
          provider.ncOrderDetailEntity = NCOrderDetailBean.fromJson(
              json.decode(json.encode(provider.ncOrderDetailEntity)));
        },
      );
    } else {
      await HttpErrorUtil.toastCommonError(statusResponse);
    }
  }

  /// 转购销合同
  void _convertPurchaseAction(NCOrderDetailProvider provider) async {
    var response = await Request.instance.existUnpay(provider.ncOrderId);
    if (response.isSuccess()) {
      var model = ExistUnpayBean.fromJson(response.data ?? {});
      if (model.result == true) {
        await Fluttertoast.showToast(msg: model.total ?? '');
      } else {
        ///不存在
        await NCConvertPurchase.show(
            shopId: provider.ncOrderDetailEntity.shopId ?? -1,
            signType: provider.ncOrderDetailEntity.signType,
            ncOrderId: provider.ncOrderId);
      }
    } else {
      await HttpErrorUtil.toastCommonError(response);
    }
  }

  /// 跳转修改收款账户页面
  void pushChangeBankCardPage(NCOrderDetailProvider provider) async {
    var response = await Request.instance
        .verifyChangeAccount(ncOrderId: provider.ncOrderId);
    if (response.isSuccess()) {
      if (response.data == true) {
        var value = provider.ncOrderDetailEntity;
        await Rrc58RouterBridge.navigateTo(context,
            routeName: RouteNames.pathNCOrderChangeBankCard, params: {});
      }
    } else {
      await HttpErrorUtil.toastCommonError(response);
    }
  }
}

class ExistUnpayBean {
  bool? result;
  String? total;

  ExistUnpayBean({this.result, this.total});

  ExistUnpayBean.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['result'] = result;
    data['total'] = total;
    return data;
  }
}
