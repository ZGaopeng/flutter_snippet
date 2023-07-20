class NcCollectionContractPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NcCollectionContractState();

  NcCollectionContractPage({required this.json});

  final String json;
}

class _NcCollectionContractState extends State<NcCollectionContractPage>
    with WidgetsBindingObserver {
  //默认第一页
  late PageController controller;
  late NcEditCollectionContractVM _collectionContractVM;
  late NcContractCapitalPoolProvider _ncContractCapitalPoolProvider;
  BuildContext? mContext;

  bool initFinish = false;

  @override
  void initState() {
    super.initState();
    NetworkLoggerUtil.attachOverlayButton(context);
    WidgetsBinding.instance.addObserver(this);
    _collectionContractVM = NcEditCollectionContractVM(intentJson: widget.json);
    controller = PageController(
      initialPage: _collectionContractVM.currentPage,
    );
    _initData();
  }

  //初始化数据和状态
  Future<void> _initData() async {
    //更新状态
    if (mounted) {
      setState(() {
        initFinish = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;
    return WillPopScope(
      onWillPop: () {
        if (_collectionContractVM.currentPage == null ||
            _collectionContractVM.currentPage == 0) {
          NavigatorUtil.pop(context);
        } else {
          if (!fastClickUtil.isFastClick()) {
            toPage(index: --_collectionContractVM.currentPage);
          }
        }
        return Future.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: RrcAppBar.getAppBar(context, title: Strings.NC_CONTRACT,
            onLeadingClick: () {
          if (_collectionContractVM.currentPage == null ||
              _collectionContractVM.currentPage == 0) {
            NavigatorUtil.pop(context);
          } else {
            if (fastClickUtil.isFastClick()) return;
            toPage(index: --_collectionContractVM.currentPage);
          }
        }),
        backgroundColor: Color(0xFFF8F8FA),
        body: SafeArea(
          child: initFinish
              ? MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: ((context) => _collectionContractVM)),
                    ChangeNotifierProvider(
                        create: ((context) => _ncContractCapitalPoolProvider)),
                  ],
                  child: Consumer<NcEditCollectionContractVM>(
                    builder: ((context, model, child) {
                      return Column(
                        children: [
                          if (model.isUserNcRole == true) _capitalPoolWidget(),
                          Container(
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                getTitleBar(0, '车辆信息'),
                                getTitleBar(1, '卖家信息'),
                                getTitleBar(2, '收款账号'),
                                getTitleBar(3, '车价')
                              ],
                            ),
                          ),
                          Expanded(
                            child: child!,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: BottomDoubleButton(
                                _collectionContractVM.currentPage,
                                totalPage: 4, onPreStep: () {
                              if (fastClickUtil.isFastClick()) return;
                              toPage(
                                  index: --_collectionContractVM.currentPage);
                            }, onNextStep: () {
                              if (_collectionContractVM.currentPage == 3) {
                                submit();
                              } else {
                                if (fastClickUtil.isFastClick()) return;
                                toPage(nextStep: true);
                              }
                            }),
                          ),
                        ],
                      );
                    }),
                    child: PageView(
                      controller: controller,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        NcCarInfoPage(_collectionContractVM.ncCarInfoVM),
                        NcSellerInfoPage(_collectionContractVM.ncSellerInfoVM),
                        NcAccountSubPage(
                            model: _collectionContractVM.ncAccountVM),
                        NcCarPricePage(_collectionContractVM.ncCarPriceVM)
                      ],
                    ),
                  ),
                )
              //替换多provider，
              // BaseView<NcEditCollectionContractVM>(
              //     viewModel: _collectionContractVM,
              //     builder: (context, model, child) => Column(
              //       children: [
              //         _capitalPoolWidget(),
              //         Container(
              //           color: Colors.white,
              //           child: Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceAround,
              //             children: [
              //               getTitleBar(0, '车辆信息'),
              //               getTitleBar(1, '卖家信息'),
              //               getTitleBar(2, '收款账号'),
              //               getTitleBar(3, '车价')
              //             ],
              //           ),
              //         ),
              //         Expanded(
              //           child: child!,
              //         ),
              //         BottomButton(
              //           text: _collectionContractVM.currentPage == 3
              //               ? '提交'
              //               : '下一步',
              //           onClickListener: _collectionContractVM.currentPage == 3
              //               ? () => submit()
              //               : () => toPage(),
              //         ),
              //       ],
              //     ),
              //     child: PageView(
              //       controller: controller,
              //       physics: NeverScrollableScrollPhysics(),
              //       children: [
              //         NcCarInfoPage(_collectionContractVM.ncCarInfoVM),
              //         NcSellerInfoPage(_collectionContractVM.ncSellerInfoVM),
              //         NcAccountSubPage(
              //             model: _collectionContractVM.ncAccountVM),
              //         NcCarPricePage(_collectionContractVM.ncCarPriceVM)
              //       ],
              //     ),
              //   )
              : LoadingWidget(message: '加载中'),
        ),
      ),
    );
  }

  GestureDetector getTitleBar(int index, String name) {
    return GestureDetector(
      onTap: () {
        // Nc3.5 分步保存，取消点击title跳转页面，避免冲突
        // var nextStep = false;
        // if (_collectionContractVM.currentPage < index) {
        //   nextStep = true;
        // }
        // if (_collectionContractVM.maxPage == 3 ||
        //     index <= _collectionContractVM.maxPage + 1) toPage(index: index, nextStep: nextStep);
      },
      child:
          CommonNavigationBar(name, _collectionContractVM.currentPage == index),
    );
  }

  var listALl;

  void submit() async {
    if (fastClickUtil.isFastClick()) return;
    FocusScope.of(context).requestFocus(FocusNode());
    LoadingUtil.show(context);
    var verified = await _collectionContractVM.ncCarPriceVM.nextStep();
    if (!verified) {
      NavigatorUtil.pop(context);
      return;
    }
    var submit = await _collectionContractVM.ncCarPriceVM.submitData();
    if (!submit) {
      NavigatorUtil.pop(context);
      return;
    }

    //校验资金池
    var capticalPoolCheckResult = await _ncContractCapitalPoolProvider
        .submitCheckNet(_collectionContractVM.ncCarPriceVM.dealPrice);
    if (!capticalPoolCheckResult) return;

    listALl = <DialogConfirmContractBean>[];
    var list1 = <DialogConfirmContractItemBean>[];
    _collectionContractVM.ncCarInfoVM.items.forEach((element) {
      if (element.getTitle() != null &&
          element.getTitle().isNotEmpty &&
          element.getTitle() != Strings.CAR_DATA) {
        list1.add(DialogConfirmContractItemBean(element.title,
            rightText: element.getRightText()));
      }
    });
    var list2 = generateList2();

    var list3 = <DialogConfirmContractItemBean>[];
    _collectionContractVM.ncAccountVM.items.forEach((element) {
      if (element.getTitle() != null && element.getTitle().isNotEmpty) {
        list3.add(DialogConfirmContractItemBean(element.title,
            rightText: element.getRightText()));
      }
    });
    var list4 = <DialogConfirmContractItemBean>[];
    _collectionContractVM.ncCarPriceVM.items.forEach((element) {
      if (element.getTitle().isNotEmpty) {
        if (!_collectionContractVM.ncCarPriceVM.invisibleList
            .contains(element.paramName)) {
          list4.add(DialogConfirmContractItemBean(element.title,
              rightText: element.getRightText()));
        }
      }
    });
    if (list4.last.leftText == '补充约定') {
      list4.removeLast();
    }

    var list5 = <DialogConfirmContractItemBean>[];
    list5.add(DialogConfirmContractItemBean(
        _collectionContractVM.ncCarPriceVM.items.last.getRightText()));

    listALl.add(DialogConfirmContractBean('', list1));
    listALl.add(DialogConfirmContractBean('卖车人信息', list2));
    listALl.add(DialogConfirmContractBean('付款信息', list3));
    listALl.add(DialogConfirmContractBean('车价信息', list4));
    listALl.add(DialogConfirmContractBean('补充约定', list5));

    //展示确认合同信息弹窗
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ConfirmContractDialog(
            list: listALl,
            confirmCallback: () {
              NavigatorUtil.pop(context);
              submitContract();
            },
            cancelCallback: () => NavigatorUtil.pop(context),
          );
        });
  }

  //资金池ui
  Widget _capitalPoolWidget() {
    return NcContractCapitalPoolWidget();
  }

  List<DialogConfirmContractItemBean> generateList2() {
    var list = _collectionContractVM.ncSellerInfoVM
        .stateWidgetsMap?[_collectionContractVM.ncSellerInfoVM.currentState];
    var addr = '';
    var list2 = <DialogConfirmContractItemBean>[];
    _collectionContractVM.ncSellerInfoVM.items.forEach((w) {
      if (list?.contains(w.paramName) == true) {
        if (w is EditWidget) {
          if (w.title == Strings.NC_ADDRESS) {
            addr = addr + w.getRightText();
          } else {
            if (_collectionContractVM.ncSellerInfoVM.currentState ==
                    NcSellerInfoStateEnum.OWNER_PERSONAL &&
                _collectionContractVM.ncSellerInfoVM.ownerIDType == 1) {
              if (w.paramName == Strings.NC_SELLER_OWNER_ID_TYPE_KEY ||
                  w.paramName == Strings.NC_OWNER_NAME_KEY ||
                  w.paramName == Strings.NC_OWNER_ID_NUMBER_KEY ||
                  w.paramName == Strings.NC_OWNER_PHONE_KEY) {
                /// 大陆居民
                list2.add(DialogConfirmContractItemBean(w.title,
                    rightText: w.getRightText()));
              }
            } else if (_collectionContractVM.ncSellerInfoVM.currentState ==
                    NcSellerInfoStateEnum.OWNER_PERSONAL &&
                _collectionContractVM.ncSellerInfoVM.ownerIDType == 2) {
              if (w.paramName == Strings.NC_SELLER_OWNER_ID_TYPE_KEY ||
                  w.paramName == Strings.NC_OWNER_NAME_NOT_MAINLAND_KEY ||
                  w.paramName == Strings.NC_OWNER_ID_NUMBER_NOT_MAINLAND_KEY ||
                  w.paramName == Strings.NC_OWNER_PHONE_NOT_MAINLAND_KEY) {
                /// 非大陆居民
                list2.add(DialogConfirmContractItemBean(w.title,
                    rightText: w.getRightText()));
              }
            } else {
              list2.add(DialogConfirmContractItemBean(w.title,
                  rightText: w.getRightText()));
            }
          }
          if (w.title == Strings.NC_AGENT_PHONE &&
              (_collectionContractVM.ncSellerInfoVM.currentState !=
                      NcSellerInfoStateEnum.OWNER_PERSONAL ||
                  _collectionContractVM.ncSellerInfoVM.currentState !=
                      NcSellerInfoStateEnum.OWNER_PUBLIC)) {
            list2.add(DialogConfirmContractItemBean('是否有车主信息',
                rightText: _collectionContractVM.ncSellerInfoVM.exist_owner == 0
                    ? '无'
                    : '有'));
          }
        } else if (w is SelectWidget) {
          list2.add(DialogConfirmContractItemBean(w.title,
              rightText: w.getRightText()));
        }
      }
    });
    list2.add(
        DialogConfirmContractItemBean(Strings.NC_ADDRESS, rightText: addr));
    return list2;
  }

  //提交合同
  void submitContract() {
    //展示加载框
    LoadingUtil.show(context,
        barrierDismissible: false, cancelAble: false, message: '正在创建合同...');
    _collectionContractVM.submitContract(errorCallback: (msg, back) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext dialogContext) {
            return ThemeDialog(
              title: '提示',
              content: msg,
              positiveText: '好的',
              positiveFun: (BuildContext dialogContext) async {
                //关闭提示框
                NavigatorUtil.pop(dialogContext);
                //关闭加载框
                NavigatorUtil.pop(dialogContext);
                //如果要退出界面，则关闭界面
                if (back && mounted) NavigatorUtil.pop(context);
              },
            );
          });
    }, successCallback: (contractUrl, contractNum, isOfflineSign) {
      //关闭加载框
      NavigatorUtil.pop(context);
      if (!isOfflineSign) {
        /// 线上
        Navigator.of(mContext ?? context).push(
          MaterialPageRoute(
            builder: (context) => CommonWebViewPage(
              contractUrl,
              displayAppBar: false,
              onPageStart: (url) {
                toPdfPage(url, contractNum);
              },
              userAgentHandler: UserAgentHandler.systemUA(),
            ),
          ),
        );
      } else {
        /// 线下
        var params = {'url': contractUrl};
        HandleH5ThemeUtil.handleThemeColor(RouteNames.pathH5, params);
        Rrc58RouterBridge.navigateTo(mContext ?? context,
            routeName: RouteNames.pathH5,
            params: params,
            pushAndRemoveUntil: (name) => name == RouteNames.pathHome);
      }
    });
  }

  Future<void> toPdfPage(String url, String contractNumber) async {
    // 监听法大大合同签字成功并提交
    if (url.contains('?')) url = url.substring(0, url.indexOf('?'));
    if (_collectionContractVM.carId != null &&
        HandleUrlUtil.handleThirdPartyContract(url)) {
      var result =
          await Request.instance.needSendMsg(_collectionContractVM.carId!);
      if (result == null || result.status != 0) {
        if (result != null && result.err_msg != null) {
          await Fluttertoast.showToast(msg: result.err_msg);
        }
        return;
      }
      if (result.data) {
        await Rrc58RouterBridge.navigateTo(
          context,
          routeName: RouteNames.pathPdfNCContract,
          params: {
            'title': '合同信息',
            'carId': _collectionContractVM.carId?.toString(),
            'contractNumber': contractNumber,
            'pdfUrl': ''
          },
          pushAndRemoveUntil: (name) => false,
        );
      } else {
        //当是车主的情况：跳转到签署成功页面
        await Rrc58RouterBridge.navigateTo(
          context,
          routeName: RouteNames.pathNCContractSignedComplete,
          params: {
            'contractNumber': contractNumber,
            'isFromNC': '1',
          },
          pushAndRemoveUntil: (name) => false,
        );
      }
    }
  }

  void toPage({int? index, bool nextStep = false}) async {
    FocusScope.of(context).requestFocus(FocusNode());
    var toNextPage = true;
    index = index ?? _collectionContractVM.currentPage + 1;
    if (nextStep) {
      switch (_collectionContractVM.currentPage) {
        case 0:
          toNextPage = index < _collectionContractVM.currentPage ||
              await _collectionContractVM.ncCarInfoVM.nextStep();
          break;
        case 1:
          toNextPage = index < _collectionContractVM.currentPage ||
              await _collectionContractVM.ncSellerInfoVM.nextStep();
          if (toNextPage &&
              (_collectionContractVM
                          .commonMap[NcEditCollectionContractVM.isUserNbRole] ==
                      true ||
                  _collectionContractVM.commonMap[
                          NcEditCollectionContractVM.isUserWbHelpBuyRole] ==
                      true)) {
            // NB或58帮买角色时传值
            var model = _collectionContractVM.ncSellerInfoVM.getAccountInfo();
            _collectionContractVM.ncAccountVM.setBankVerifiedModel(model);
          }
          break;
        case 2:
          toNextPage = index < _collectionContractVM.currentPage ||
              await _collectionContractVM.ncAccountVM.nextStep();
          await _collectionContractVM.ncCarPriceVM.getSignType();
          break;
      }
    }
    if (toNextPage) {
      if (nextStep) {
        var submitSuccess = await submitInfo(_collectionContractVM.currentPage);
        if (!submitSuccess) {
          return;
        }
      }
      controller.jumpToPage(index);
      _collectionContractVM.setCurrentPage(index);
    }
  }

  double oldBottom = 0;
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var currentBottom = MediaQuery.of(context).viewInsets.bottom;
      // 如果currentBottom为0，表示键盘消失了，这时候整个界面获取焦点，那TextField自然就失去焦点了
      // 为什么还要判断oldBottom，因为在界面没变化的时候，个别机型也会调用这个方法
      // 所以必须在oldBottom不为0的时候，才获取焦点，这里很坑。。。
      if (oldBottom != 0 && currentBottom == 0) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
      oldBottom = currentBottom;
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
