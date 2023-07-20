///主页页面
class MainTabHomePage extends StatefulWidget {
  final GlobalKey contentKey;
  const MainTabHomePage({Key? key, required this.contentKey}) : super(key: key);

  @override
  _MainTabHomePageState createState() => _MainTabHomePageState();
}

class _MainTabHomePageState extends State<MainTabHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final MainTabHomeProvider provider = MainTabHomeProvider();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      primary: true, //沉浸式状态栏
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '工作台',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => provider),
          ChangeNotifierProvider(create: (_) => HomeSaleTaskProvider()),
          ChangeNotifierProvider(create: (_) => HomeTodayDataProvider()),
          ChangeNotifierProvider(create: (_) => SaleResourcesBoardProvider()),
        ],
        child: LoginUtil.isLogin()
            ? MainTabHomePageContent(key: widget.contentKey)
            : MainTabHomeNotLoggedInPage(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    provider.dispose();
  }
}

class MainTabHomePageContent extends StatefulWidget {
  const MainTabHomePageContent({Key? key}) : super(key: key);

  @override
  _MainTabHomePageContentState createState() => _MainTabHomePageContentState();
}

class _MainTabHomePageContentState extends State<MainTabHomePageContent>
    with RouteAware, WidgetsBindingObserver {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _refreshFrequently();
  }

  //监听程序进入前后台的状态改变的方法
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      //进入应用时候不会触发该状态 应用程序处于可见状态，并且可以响应用户的输入事件
      case AppLifecycleState.resumed:
        _refreshFrequently();
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //检查是否需要更新
      var bean = await RrcAppUpdate.checkUpdate(
          context, UserStore.getUserIdStr(),
          allCheck: true);
      if (bean != null) {
        bean.iosAppId = AppConfig.IosAppId;
        //显示默认更新弹窗
        RrcAppUpdate.showUpdateDialog(context, bean,
            installType: InstallType.download);
      }
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F3F7),
      child: RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: Consumer<MainTabHomeProvider>(
          builder: (BuildContext context, MainTabHomeProvider provider,
              Widget? child) {
            return ListView(
              children: [_newBuild(context, provider)],
            );
          },
        ),
      ),
    );
  }

  ///手动下拉刷新
  Future<void> _refreshData() async {
    if (mounted)
      await Provider.of<MainTabHomeProvider>(context, listen: false).refresh();
    if (mounted)
      await Provider.of<HomeSaleTaskProvider>(context, listen: false)
          .requestData();
    if (mounted)
      await Provider.of<HomeTodayDataProvider>(context, listen: false)
          .requestData();
    if (mounted)
      await Provider.of<SaleResourcesBoardProvider>(context, listen: false)
          .requestSaleCustomerManageData();
    if (mounted && SettingsConfig.getSyncStore()?.envType == EnvType.TESTING) {
      // 测试环境下，存储Web配置信息
      var result = await WebEnvUtil.requestWebEnvData();
      await WebEnvUtil.setWebEnvJsonData(result);
      await SettingsConfig.refreshSyncStore();
    }
  }

  ///经常刷新（返回当前页）
  Future<void> _refreshFrequently() async {
    await Provider.of<MainTabHomeProvider>(context, listen: false).refresh();
  }

  // 新首页布局
  Widget _newBuild(BuildContext context, MainTabHomeProvider provider) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFFF2F3F7)),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 208,
              ),
              Positioned(
                  child: ClipPath(
                clipper: MyClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    color: RrcColors.themeColor,
                  ),
                  height: 77,
                ),
              )),
              Positioned(
                  top: 11,
                  left: 17,
                  right: 17,
                  child: Container(
                    height: 197,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    child: _myServices(context, provider),
                  ))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 9, left: 16, right: 16.0),
            child: Container(
              height: 107,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: TabHomeBanner(),
              ),
            ),
          ),

          /// 销售代办任务
          HomeSaleTaskWidget(),

          /// 今日数据
          HomeTodayData(),

          // 资源看板
          HomeSaleBoardDataItem(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 我的服务
  Widget _myServices(BuildContext context, MainTabHomeProvider provider) {
    var itemCount = provider.myServicesList.length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(top: 13, left: 14),
              child: Text(
                '我的服务',
                style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MainTabHomeAllMenuPage(
                          allDynamicMenus: provider.allDynamicMenus,
                        )));
              },
              child: Container(
                padding: EdgeInsets.only(right: 14),
                child: Text(
                  '查看更多 >',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666670),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //横轴元素个数
              crossAxisCount: 4,
              //纵轴间距
              mainAxisSpacing: 14.0,
              //横轴间距
              crossAxisSpacing: 0,
              //子组件宽高长度比例
              childAspectRatio: 1.57,
            ),
            itemBuilder: (context, index) {
              return _buildItemView(index, provider);
            },
            itemCount: itemCount > 8 ? 8 : itemCount,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: false),
      ],
    );
  }

  Widget _buildItemView(int index, MainTabHomeProvider provider) {
    var item = provider.myServicesList[index];
    var defaultIcon = 'assets/images/icon_main_tab_home_services_default.png';
    var unReadNum = int.tryParse(item.extendParams?['todoCount'] ?? '') ?? 0;
    return GestureDetector(
      onTap: () {
        HandleH5ThemeUtil.handleThemeColor(item.route ?? '', item.params ?? {});
        Rrc58RouterBridge.navigateTo(context,
            routeName: item.route ?? '', params: item.params ?? {});
      },
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                child: CachedNetworkImage(
                  imageUrl: item.iconUrl ?? '',
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Image.asset(defaultIcon),
                  errorWidget: (context, url, _) => Image.asset(defaultIcon),
                ),
              ),
              SizedBox(
                height: 3.5,
              ),
              Text(
                item.des ?? '',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Positioned(
              top: 0,
              right: 10,
              child: unReadNum > 0
                  ? Container(
                      alignment: Alignment.center,
                      padding: unReadNum == 1
                          ? EdgeInsets.only(left: 5.5, right: 5.5)
                          : EdgeInsets.only(left: 4.5, right: 4.5),
                      height: 16.0,
                      decoration: BoxDecoration(
                          color: Color(0xFFFF3535),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        unReadNum > 99 ? '99+' : unReadNum.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 10.0),
                      ),
                    )
                  : Container())
        ],
      ),
    );
  }

  // 旧首页
  Widget _oldBuild(BuildContext context, MainTabHomeProvider provider) {
    return CustomScrollView(
      slivers: <Widget>[
        //AppBar，包含一个导航栏
        renderSliverAppBar(context),

        // 提醒条
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: renderNoticeInfo(),
        ),

        // H5 我的服务
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: renderDynamicMenusH5Title(),
        ),

        // H5 DynamicMenus
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: renderDynamicMenusH5(provider),
        ),

        // Native 我的功能
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: renderDynamicMenusNativeTitle(),
        ),

        // Native DynamicMenus
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: renderDynamicMenusNative(context, provider),
        ),

        // 售车服务
        SliverPadding(
          padding: EdgeInsets.all(8.0),
          sliver: renderDynamicMenusSaleTitle(),
        ),

        // 售车服务 DynamicMenus
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: renderDynamicMenusSale(context, provider),
        ),
      ],
    );
  }
}
