class NCOrderChangeApplicationContent extends StatefulWidget {
  final NcAccountVM ncAccountVM;
  const NCOrderChangeApplicationContent({Key? key, required this.ncAccountVM})
      : super(key: key);

  @override
  State<NCOrderChangeApplicationContent> createState() =>
      _NCOrderChangeApplicationContentState();
}

class _NCOrderChangeApplicationContentState
    extends State<NCOrderChangeApplicationContent> {
  late NcAccountVM _ncAccountVM;

  SelectOneWidget? accountTypeWidget;

  /// 账户姓名/账户名称
  EditWidget? accountNameWidget;

  /// 身份证号
  EditWidget? accountIDNumberWidget;

  /// 银行卡号
  EditWidget? bankNumberWidget;

  UploadWidget? uploadWidget;

  @override
  void initState() {
    super.initState();
    _ncAccountVM = widget.ncAccountVM;
    accountTypeWidget = SelectOneWidget(
      title: '账户类型',
      titlePadding: EdgeInsets.only(right: 10),
      paramName: '',
      leftText: '个人',
      rightText: '公户',
      leftValue: 1,
      rightValue: 2,
      value: 1,
      horizontalMargin: 0,
      horizontalAlignment: MainAxisAlignment.start,
      onChange: (value) async {
        _ncAccountVM.accountInfoBean?.accountType = value;
        _ncAccountVM.bankName = '';
        _ncAccountVM.bankId = '';
        _ncAccountVM.accountInfoBean?.bankId = '';
        _ncAccountVM.accountInfoBean?.bankName = '';
        if (_ncAccountVM.accountInfoBean?.accountType == 1) {
          _ncAccountVM.notifyListeners();
          await _ncAccountVM
              .queryBankName(_ncAccountVM.accountInfoBean?.bankNumber ?? '');
          if (_ncAccountVM.accountInfoBean?.accountType == 1) {
            /// 快速切换
            _ncAccountVM.accountInfoBean?.bankName = _ncAccountVM.bankName;
          }
        }
        _ncAccountVM.notifyListeners();
      },
    )..setValue(_ncAccountVM.accountInfoBean?.accountType);

    accountNameWidget = EditWidget(
      title: '账户姓名',
      paramName: Strings.NC_ACCOUNT_NAME_KEY,
      margin: EdgeInsets.zero,
      rightFontSize: 16,
      rightContentPadding: EdgeInsets.symmetric(horizontal: 12),
      rightTextAlign: TextAlign.left,
      height: 32.0,
      rightDecoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xFFDCDCDC)),
          borderRadius: BorderRadius.circular(4.0)),
      onChanged: (String? input) {
        _ncAccountVM.accountInfoBean?.accountName = input;
        _ncAccountVM.bankVerifiedModel?.accountName = input;
        if (input == null) return;
        if (input.length > 25) {
          input = input.substring(0, 25);
          accountNameWidget?.setValue(input);
          _ncAccountVM.accountInfoBean?.accountName = input;
          _ncAccountVM.bankVerifiedModel?.accountName = input;
          return;
        }
      },
    )..setRightText(_ncAccountVM.accountInfoBean?.accountName ??
        _ncAccountVM.bankVerifiedModel?.accountName);

    accountIDNumberWidget = EditWidget(
      title: Strings.NC_ACCOUNT_ID_NUMBER,
      paramName: Strings.NC_ACCOUNT_ID_NUMBER_KEY,
      hintText: Strings.NC_ACCOUNT_ID_NUMBER,
      margin: EdgeInsets.zero,
      rightFontSize: 16,
      rightContentPadding: EdgeInsets.symmetric(horizontal: 12),
      rightTextAlign: TextAlign.left,
      height: 32.0,
      rightDecoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xFFDCDCDC)),
          borderRadius: BorderRadius.circular(4.0)),
      onChanged: (text) {
        if (text == null) return;
        if (text.length > 18) {
          text = text.substring(0, 18);
          accountIDNumberWidget?.setValue(text);
        }
        _ncAccountVM.accountInfoBean?.accountIdNumber = text;
        _ncAccountVM.bankVerifiedModel?.accountIdNumber = text;
      },
    )..setRightText(_ncAccountVM.accountInfoBean?.accountIdNumber);

    bankNumberWidget = EditWidget(
      title: Strings.NC_BANK_NUMBER,
      paramName: Strings.NC_BANK_NUMBER_KEY,
      margin: EdgeInsets.zero,
      rightFontSize: 16,
      rightContentPadding: EdgeInsets.symmetric(horizontal: 12),
      rightTextAlign: TextAlign.left,
      height: 32.0,
      rightDecoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color(0xFFDCDCDC)),
          borderRadius: BorderRadius.circular(4.0)),
      maxLines: 1,
      editType: EditType.BankNum,
      onChanged: (text) {
        _ncAccountVM.bankNumber =
            text.replaceAll(Rules.instance.middleSpaceRegExp, '');
        _ncAccountVM.bankVerifiedModel?.bankNumber =
            text.replaceAll(Rules.instance.middleSpaceRegExp, '');
        _ncAccountVM.accountInfoBean?.bankNumber =
            text.replaceAll(Rules.instance.middleSpaceRegExp, '');
        bankNumberWidget?.setValue(text);
        bankNumberWidget?.setRightText(text);
      },
      onEditingComplete: (text) async {
        if (_ncAccountVM.accountInfoBean?.accountType == 1) {
          await _ncAccountVM.queryBankName(text);
          _ncAccountVM.accountInfoBean?.bankName = _ncAccountVM.bankName;
          _ncAccountVM.notifyListeners();
        }
        _ncAccountVM.accountInfoBean?.bankNumber = text;
      },
    )..setRightText(_ncAccountVM.accountInfoBean?.bankNumber);

    uploadWidget = UploadWidget(
      title: '车主手持身份证图片\n或营业执照',
      id: '',
      paramName: '',
      thumbnail: '',
      imageUrl: '',
      canEditPic: true,
      margin: EdgeInsets.symmetric(vertical: 4.0),
      textStyle: TextStyle(fontSize: 14.0, color: Color(0xFF666666)),
      onChanged: (value) {
        _ncAccountVM.accountInfoBean?.applicantImage = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return _ncAccountVM;
      },
      child: Container(
        padding: EdgeInsets.only(top: 52, bottom: 87),
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Consumer<NcAccountVM>(builder: (context, provider, child) {
              return Column(
                children: [
                  accountTypeWidget!,
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: accountNameWidget!),
                  Visibility(
                      visible: provider.accountInfoBean?.accountType == 1,
                      child: accountIDNumberWidget!),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: bankNumberWidget!,
                  ),
                  TextFieldAndSelectedWidget('开户行',
                      controllerText1: provider.accountInfoBean?.bankName,
                      hintText1: '请选择开户行',
                      changeAble: false,
                      needSuffixIcon: true, onSelect: () async {
                    if (_ncAccountVM.accountInfoBean?.accountType == 1) {
                      return;
                    }
                    var bankNameList = await _ncAccountVM.getBankNameList();
                    var list = bankNameList
                        .map((e) => e['bankName'].toString())
                        .toList();
                    if (ObjectUtil.isEmptyList(list)) {
                      await Fluttertoast.showToast(msg: '获取开户行失败');
                      return;
                    }
                    BottomSheetWithPicker.showBottomCommonPicker(
                        pageContext: context,
                        mainTitle: Strings.NC_BANK_NAME,
                        list: list,
                        initPosition1: 0,
                        supportSearch: true,
                        searchHintText: '搜索开户行',
                        showBoxShadow: false,
                        onEditingComplete: (value) async {
                          var bankNameList =
                              await _ncAccountVM.getBankNameList(name: value);
                          return Future.value(bankNameList
                              .map((e) => e['bankName'].toString())
                              .toList());
                        },
                        confirm: (int position) {
                          if (position < _ncAccountVM.bankNameList.length) {
                            _ncAccountVM.bankId =
                                _ncAccountVM.bankNameList[position]['bankId'];
                            _ncAccountVM.bankName =
                                _ncAccountVM.bankNameList[position]['bankName'];
                            _ncAccountVM.accountInfoBean?.bankId =
                                _ncAccountVM.bankNameList[position]['bankId'];
                            _ncAccountVM.accountInfoBean?.bankName =
                                _ncAccountVM.bankNameList[position]['bankName'];
                            _ncAccountVM.accountInfoBean?.subBranchName = '';
                            _ncAccountVM.notifyListeners();
                          }
                        });
                  }),
                  Visibility(
                    visible: provider.accountInfoBean?.accountType == 2,
                    child: TextFieldAndSelectedWidget(
                      '开户行\n所在地',
                      controllerText1: provider.accountInfoBean?.bankProcinve,
                      controllerText2: provider.accountInfoBean?.bankCity,
                      hintText1: '省',
                      hintText2: '市',
                      changeAble: false,
                      needSuffixIcon: true,
                      doubleList: true,
                      onSelect: () async {
                        var provinceList =
                            await _ncAccountVM.getBankNameOfProvinceList();
                        var list = provinceList
                            .map((e) => e['provinceName'].toString())
                            .toList();
                        if (ObjectUtil.isEmptyList(list)) {
                          await Fluttertoast.showToast(msg: '获取省份信息失败');
                          return;
                        }
                        BottomSheetWithPicker.showBottomCommonPicker(
                            pageContext: context,
                            mainTitle: Strings.NC_BANK_LOCATION,
                            list: list,
                            initPosition1: 0,
                            confirm: (int position) {
                              if (position <
                                  _ncAccountVM.bankNameOfProvinceList.length) {
                                _ncAccountVM.provinceCode = _ncAccountVM
                                        .bankNameOfProvinceList[position]
                                    ['provinceCode'];
                                _ncAccountVM.provinceName = _ncAccountVM
                                        .bankNameOfProvinceList[position]
                                    ['provinceName'];
                                _ncAccountVM.accountInfoBean?.bankProcinveId =
                                    _ncAccountVM
                                            .bankNameOfProvinceList[position]
                                        ['provinceCode'];
                                _ncAccountVM.accountInfoBean?.bankProcinve =
                                    _ncAccountVM
                                            .bankNameOfProvinceList[position]
                                        ['provinceName'];
                                _ncAccountVM.accountInfoBean?.bankCityId = '';
                                _ncAccountVM.accountInfoBean?.bankCity = '';
                                _ncAccountVM.notifyListeners();
                              }
                            });
                      },
                      onSelectSecond: () async {
                        if (ObjectUtil.isEmptyString(
                            _ncAccountVM.accountInfoBean?.bankProcinveId)) {
                          await Fluttertoast.showToast(msg: '请先选择省份');
                          return;
                        }
                        var cityList =
                            await _ncAccountVM.getBankNameOfCityList();
                        var list = cityList
                            .map((e) => e['cityName'].toString())
                            .toList();
                        if (ObjectUtil.isEmptyList(list)) {
                          await Fluttertoast.showToast(msg: '当前城市为空');
                          return;
                        }
                        BottomSheetWithPicker.showBottomCommonPicker(
                            pageContext: context,
                            mainTitle: Strings.NC_BANK_LOCATION,
                            list: list,
                            initPosition1: 0,
                            confirm: (int position) {
                              if (position <
                                  _ncAccountVM.bankNameOfCityList.length) {
                                _ncAccountVM.cityName = _ncAccountVM
                                    .bankNameOfCityList[position]['cityName'];
                                _ncAccountVM.cityCode = _ncAccountVM
                                    .bankNameOfCityList[position]['cityCode'];
                                _ncAccountVM.accountInfoBean?.bankCityId =
                                    _ncAccountVM.bankNameOfCityList[position]
                                        ['cityCode'];
                                _ncAccountVM.accountInfoBean?.bankCity =
                                    _ncAccountVM.bankNameOfCityList[position]
                                        ['cityName'];
                                _ncAccountVM.accountInfoBean?.subBranchName =
                                    '';
                                _ncAccountVM.notifyListeners();
                              }
                            });
                      },
                    ),
                  ),
                  Visibility(
                    visible: provider.accountInfoBean?.accountType == 2,
                    child: TextFieldAndSelectedWidget('支行名称',
                        controllerText1:
                            _ncAccountVM.accountInfoBean?.subBranchName,
                        hintText1: '请选择支行',
                        changeAble: false,
                        needSuffixIcon: true, onSelect: () async {
                      if ((ObjectUtil.isEmptyString(
                              _ncAccountVM.accountInfoBean?.bankId) ||
                          ObjectUtil.isEmptyString(
                              _ncAccountVM.accountInfoBean?.bankProcinveId) ||
                          ObjectUtil.isEmptyString(
                              _ncAccountVM.accountInfoBean?.bankCityId))) {
                        await Fluttertoast.showToast(msg: '请先选择开户行和开户行所在地');
                        return;
                      }
                      var subBankNameList =
                          await _ncAccountVM.getSubBankNameList();
                      var list =
                          subBankNameList.map((e) => e.toString()).toList();
                      if (ObjectUtil.isEmptyList(list)) {
                        await Fluttertoast.showToast(msg: '当前城市支行为空');
                        return;
                      }
                      BottomSheetWithPicker.showBottomCommonPicker(
                          pageContext: context,
                          mainTitle: Strings.NC_SUB_BANK_NAME,
                          list: list,
                          initPosition1: 0,
                          supportSearch: true,
                          searchHintText: '搜索支行',
                          showBoxShadow: false,
                          onEditingComplete: (value) async {
                            var subBankNameList = await _ncAccountVM
                                .getSubBankNameList(branchBankName: value);
                            return Future.value(subBankNameList
                                .map((e) => e.toString())
                                .toList());
                          },
                          confirm: (int position) {
                            if (position <
                                _ncAccountVM.subBankNameList.length) {
                              _ncAccountVM.accountInfoBean?.subBranchName =
                                  _ncAccountVM.subBankNameList[position];
                              _ncAccountVM.notifyListeners();
                            }
                          });
                    }),
                  ),
                  uploadWidget!,
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
