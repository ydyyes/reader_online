@file:JvmName("BookApi")

package com.bule.free.ireader.api

import com.bule.free.ireader.model.*
import com.bule.free.ireader.model.bean.*
import com.bule.free.ireader.model.objectbox.bean.BookBean
import com.bule.free.ireader.model.bean.BookChapterBean
import io.reactivex.Completable
import io.reactivex.Single
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.http.Body
import retrofit2.http.Multipart
import retrofit2.http.POST
import retrofit2.http.Part

/**
 * Created by suikajy on 2019/2/22
 */
interface BookApi {

    // 登录
    @POST("ApinRegist/1")
    fun loginReg(@Body data: String): Single<LoginRegBean>

    // 获取书城分类
    @POST("Cate/1")
    fun getCategory(@Body data: String): Single<List<CategoryBean>>

    // 获取首页轮播图
    @POST("Banners/1")
    fun getBanner(@Body data: String): Single<List<BannerBean>>

    // 获取书城列表
    @POST("Novel/1")
    fun getBookMallList(@Body data: String): Single<List<BookMallItemBean>>

    // 获取书籍详情
    @POST("Detail/1")
    fun getBookDetail(@Body data: String): Single<BookDetailPageBean>

    // 获取短信验证码
    @POST("sms/1")
    fun getSmsCode(@Body data: String): Single<List<Unit>>

    // 反馈
    @POST("Feecba/1")
    fun feedBack(@Body data: String): Single<List<Unit>>

    // 获取首页和书城推荐书籍
    @POST("ReCommence/1")
    fun getRecommend(@Body data: String): Single<List<BookBean>>

    // 搜索
    @POST("Search/1")
    fun getSearchList(@Body data: String): Single<List<BookDetailBean>>

    // 搜索关键字
    @POST("Key/1")
    fun getSearchHot(@Body data: String): Single<List<String>>

    // 绑定手机
    @POST("Bindph/1")
    fun bindPhone(@Body data: String): Single<LoginRegBean>

    // 更新
    @POST("Upgrad/1")
    fun updateVersion(@Body data: String): Single<UpdateVersionBean>

    // 刷新用户信息
    @POST("UserIn/1")
    fun refreshUserInfo(@Body data: String): Single<UserInfoBean>

    // 获取广告展示策略
    @POST("VthStra/1")
    fun getAdvStrategy(@Body data: String): Single<AdvStrategyBean>
}

/**
 * 接口2.0
 */
interface BookApi2 {

    // 获取任务列表
    @POST("Ta/1")
    fun missionList(@Body data: String): Single<List<MissionBean2>>

    // 签到对应金额
    @POST("VtwSign/1")
    fun signGoldList(@Body data: String): Single<List<SignGoldBean>>

    // 任务上报
    @POST("VtwTaskPro/1")
    fun missionPost(@Body data: String): Single<MissionPostBean>

    // 金币兑换
    @POST("VtwGold/1")
    fun goldExchange(@Body data: String): Completable

    // 金币兑换列表
    @POST("VtwExchange/1")
    fun goldExchangeList(@Body data: String): Single<List<GoldExchangeItemBean>>

    // 金币明细
    @POST("VtwGoldLog/1")
    fun goldRecordList(@Body data: String): Single<List<GoldRecordBean>>

    // 初始化加载app任务对应次数列表
    @POST("VtwTaskStatus/1")
    fun missionInitData(@Body data: String): Single<MissionInitDataBean>

    // 邀请好友列表
    @POST("VtwInviationLog/1")
    fun inviteFriendRecord(@Body data: String): Single<List<InviteFriItemBean>>

    // 编辑用户信息
    @Multipart
    @POST("VtwSetUserInfo/1")
    fun editUserInfo(@Part("sign") sign: RequestBody, @Part portrait: MultipartBody.Part?): Completable
}

/**
 * 接口3.0
 */
interface BookApi3 {

    // 获取章节列表
    @POST("VthChapterLt/1")
    fun getChapterList(@Body data: String): Single<List<BookChapterBean>>

    // 获取章节内容
    @POST("VthChapterIn/1")
    fun getChapterContent(@Body data: String): Single<ChapterContentBean>

    // 添加/删除书签接口
    @POST("VthMarkSave/1")
    fun toggleBookmark(@Body data: String): Completable

    // 书签列表接口
    @POST("VthMarkRe/1")
    fun getBookmarkList(@Body data: String): Single<List<BookmarkBean>>

    // 商品列表
    @POST("VthProduct/1")
    fun getProductList(@Body data: String): Single<List<ProductBean>>

    // 商品列表
    @POST("VthOrder/1")
    fun getPayOrder(@Body data: String): Single<PayOrder>

    // 订单列表
    @POST("VthOrderRed/1")
    fun getPayLog(@Body data: String): Single<List<PayLogBean>>

    // 新版书城接口
    @POST("VthBookM/1")
    fun getNewBookMall(@Body data: String): Single<BookMallBean3_0>

    // 获取分类列表
    @POST("VthCates/1")
    fun getBookCateList(@Body data: String): Single<BookCateListBean>

    // 首页获取每日推荐书籍
    @POST("VthDayRecommend/1")
    fun getTodayRecBook(@Body data: String): Single<TodayRecBookBean>

    // 书城页面点击更多之后的列表页
    @POST("VthList/1")
    fun getMoreBookList(@Body data: String): Single<List<BookMallItemBean>>

    // 广告列表
    @POST("VthAdList/1")
    fun getAdvList(@Body data: String): Single<List<AdvListBean>>

    // 弹窗接口
    @POST("VthWindows/1")
    fun getOpeningWindow(@Body data: String): Single<OpenningDialogBean>

    // 获取男频/女频书籍列表
    @POST("VthGender/1")
    fun getBookListByGender(@Body data: String):Single<List<BookMallItemBean>>
}