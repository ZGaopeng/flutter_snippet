class NCOrderDetail extends StatefulWidget {
  final String ncOrderId;
  NCOrderDetail({required this.ncOrderId});

  @override
  State<NCOrderDetail> createState() => _NCOrderDetailState();
}

class _NCOrderDetailState extends State<NCOrderDetail> {
  final NCOrderDetailProvider provider = NCOrderDetailProvider();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => provider,
        ),
      ],
      child: NCOrderContent(ncOrderId: widget.ncOrderId, provider: provider),
    );
  }
}

class NCOrderContent extends StatefulWidget {
  final String ncOrderId;
  final NCOrderDetailProvider provider;
  NCOrderContent({required this.ncOrderId, required this.provider});
  @override
  _NCOrderContentState createState() => _NCOrderContentState();
}

class _NCOrderContentState extends State<NCOrderContent> {
  late NCOrderDetailProvider provider;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    NetworkLoggerUtil.attachOverlayButton(context);
    provider = widget.provider;
    // 传递参数
    provider.ncOrderId = widget.ncOrderId;
    _subscription = rrcEventBus.listenEvent((EventFactory res) {
      if (res.type == EventType.notifyNcOrderDetailsRefreshData) {
        handleResult(context, ResultInfo());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NCOrderDetailContent(provider),
      appBar: AppBar(
        title: Text(
          '收车详情',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 返回按钮要永远存在，因为有可能返回到App上层
            NavigatorUtil.pop(context);
          },
        ),
        actions: [
          UnconstrainedBox(
              child: SizedBox(
                  width: 60,
                  height: 40,
                  child: NcOrderDetailTitleRescind(context)))
        ],
      ),
    );
  }
}

class NCOrderDetailContent extends StatefulWidget {
  final NCOrderDetailProvider provider;

  NCOrderDetailContent(this.provider);

  @override
  _NCOrderDetailContentState createState() => _NCOrderDetailContentState();
}

class _NCOrderDetailContentState extends State<NCOrderDetailContent> {
  @override
  void initState() {
    super.initState();
    widget.provider.load(context, canLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    Log.d('NCOrderDetail - build执行');
    // 全局刷新唯一的情况就是LoadState发生变化
    return Selector<NCOrderDetailProvider, LoadState>(
      selector: (BuildContext context, NCOrderDetailProvider provider) =>
          provider.layoutState,
      builder: (BuildContext context, LoadState state, Widget? child) {
        return LoadStateLayout(
            state: state,
            onTapRetry: () {
              widget.provider.load(context, canLoading: true);
            },
            onSuccess: (BuildContext context) {
              return RefreshIndicator(
                onRefresh: () async {
                  await widget.provider.load(context);
                },
                child: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Color(0xFFF8F8FA),
                          child: ListView(
                            children: [
                              NCOrderDetailStatus(),
                              SizedBox(height: 10),
                              NCOrderDetailRescind(
                                  ncOrderId: widget
                                      .provider.ncOrderDetailEntity.ncOrderId
                                      .toString()),
                              SizedBox(height: 10),
                              NCOrderDetailInfo(), // NC订单详情
                              SizedBox(height: 10),
                              NCOrderDetailSupplement(), // 补充协议
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      NCOrderDetailBottomBtn(),
                      _showCollectionBtn(),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  /// 扣款协议已签署去收款
  Widget _showCollectionBtn() {
    return Visibility(
      visible: widget.provider.ncOrderDetailEntity.canShowCollectBtn ?? false,
      child: GestureDetector(
        onTap: () => _gotoCollection(context),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(5),
          ),
          height: 40.0,
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(16, 18, 16, 15),
          child: Text(
            '扣款协议已签署去收款',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// 跳转退款信息页去收款
  Future<void> _gotoCollection(BuildContext context) async {
    var ncOrderId = widget.provider.ncOrderId;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (con) => NcOrderDeductPriceRefundInfoPage(
          ncOrderId: ncOrderId,
          pageStatus: PageStatus.Collection,
          shopId: '${widget.provider.ncOrderDetailEntity.shopId}',
          contractModelCode:
              widget.provider.ncOrderDetailEntity.contractModelCode,
        ),
      ),
    );
    handleResult(context, ResultInfo());
  }
}

/// 处理返回类型
void handleResult(BuildContext context, ResultInfo result) {
  if (result.type == ResultInfo.OK) {
    // 刷新当前页面
    Provider.of<NCOrderDetailProvider>(
      context,
      listen: false,
    ).load(context, canLoading: true);
  }
}
