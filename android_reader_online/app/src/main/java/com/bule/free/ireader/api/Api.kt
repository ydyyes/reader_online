package com.bule.free.ireader.api

import android.annotation.SuppressLint
import android.support.annotation.WorkerThread
import com.bule.free.ireader.Const
import com.bule.free.ireader.api.apiconvert.ApiRequestBodyConverter
import com.bule.free.ireader.common.paging.Paging
import com.bule.free.ireader.common.utils.AES
import com.bule.free.ireader.common.utils.LogUtils
import com.bule.free.ireader.common.utils.ServerTimeUtil
import com.bule.free.ireader.common.utils.async
import com.bule.free.ireader.model.BookmarkBean
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.bean.*
import com.bule.free.ireader.model.objectbox.bean.BookBean
import com.bule.free.ireader.model.bean.BookChapterBean
import com.google.gson.Gson
import io.reactivex.Completable
import io.reactivex.Single
import io.reactivex.functions.Consumer
import okhttp3.*
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.util.concurrent.Executors

/**
 * Created by suikajy on 2019/2/22
 */
object Api {
    // 是否使用线上服务器
    private const val IS_ONLINE = true
    // 是否打印http内容
    const val IS_API_DEBUG = Const.DEBUG
    // 线下服务器
//    private const val OFFLINE_BASE_URL = "http://online_rd.enjoynut.cn/"
    private const val OFFLINE_BASE_URL = "http://172.16.2.160:9000/"
//    private const val OFFLINE_BASE_URL = "https://45.195.84.247"
//    private const val OFFLINE_BASE_URL = "http://book.shuyumsy.com/"

    // 线上服务器
    private const val ONLINE_BASE_URL = "http://drapi.17k.ren/"
    // 最终使用的基链接
    @Suppress("ConstantConditionIf")
    val BASE_URL = if (IS_ONLINE) ONLINE_BASE_URL else OFFLINE_BASE_URL

    private val bookApi: BookApi = RemoteHelper.retrofit.create(BookApi::class.java)
    private val bookApi2: BookApi2 = RemoteHelper.retrofit.create(BookApi2::class.java)
    private val bookApi3: BookApi3 = RemoteHelper.retrofit.create(BookApi3::class.java)

    /*********************************** 接口 *************************************************/
    // 请求服务器时间，并和其同步。
    fun reqServerTime(block: () -> Unit) {
        //LogUtils.e("request Server time, api")
       RemoteHelper.simpleOkHttpClient.newCall(Request.Builder()
                .url("${BASE_URL}GetTime/1")
                .get().build()).enqueue(object : Callback {
            override fun onFailure(call: Call?, e: IOException?) {
            }

            override fun onResponse(call: Call?, response: Response?) {
                if (response?.isSuccessful == true) {
                    val serverTimeS = response.body()?.string()
                            ?: System.currentTimeMillis().toString()
                    try {
                        ServerTimeUtil.serverTime = serverTimeS.toLong()
                    } catch (e: Exception) {
                        ServerTimeUtil.serverTime = System.currentTimeMillis()
                    }
                    block()
                }
            }
        })
    }

    //检测app升级
    fun getUpdate() = bookApi.updateVersion(jsonWithNoTokenOf()).async()

    //获取手机验证码
    fun sendSmsCode(mobile: String): Single<List<Unit>> {
        return bookApi.getSmsCode(jsonWithNoTokenOf(
                "areacode" to "+86",
                "mobile" to mobile
        )).async()
    }

    //用户反馈
    fun feedBack(content: String, email: String = "") = bookApi.feedBack(jsonOf("content" to content, "email" to email)).async()

    // 登录注册接口
    fun loginReg(mobile: String, code: String): Single<LoginRegBean> {
        return bookApi.loginReg(jsonWithNoTokenOf(
                "areacode" to "+86",
                "type" to 2,
                "mobile" to mobile,
                "code" to code
        )).async()
    }

    // 获取分类数据
    fun getCategory() = bookApi.getCategory(jsonOf()).async()

    // 获取首页轮播图
    fun getBanner() = bookApi.getBanner(jsonOf()).async()

    // 获取推荐列表
    fun getRecommendList(gender: Int = 0, page: Int = 1, size: Int = 2): Single<List<BookBean>> {
        if (gender == 0) {
            return bookApi.getRecommend(jsonOf(
                    "page" to page,
                    "size" to size
            )).async()
        }
        return bookApi.getRecommend(
                jsonOf(
                        "gender" to gender,
                        "page" to page,
                        "size" to size
                )
        ).async()
    }

    fun getChapterList(id: String): Single<List<BookChapterBean>> {
        return bookApi3.getChapterList(jsonOf("id" to id)).async()
    }

    // 获取书城右侧列表
    fun getBookMallItemList(m_id: Int = -1, type: String = "", page: Int = 1, size: Int = 2): Single<List<BookMallItemBean>> {
        val jo = JSONObject().apply {
            if (m_id != -1) put("m_id", m_id) // 不传则表示全部分类
            put("token", User.token)
            if (type.isNotEmpty()) put("type", type) //上传分类的name 参数值 hot new reputation over,对应 新书 热门 口碑 完结 默认new （如果不传默认全部）
            put("page", page)
            put("size", size)
        }
        return bookApi.getBookMallList(jo.toString()).async()
    }

    // 获取书籍详情，如果是从搜索页面进来的，hotSearch = "1"
    fun getBookDetail(id: String, hotSearch: String = "") = bookApi.getBookDetail(jsonOf("id" to id, "hot_search" to hotSearch)).async()

    fun getChapterContent(id: String, label: String): Single<ChapterContentBean> {
        return getChapterContentBySync(id, label).async()
    }

    //fun get(url: String) = getBySync(url).async()

    private val get2Executor = Executors.newCachedThreadPool()

    fun get2(url: String, callback: ApiCallBack) {
        get2Executor.submit {
            try {
                val result = getBySync2(url)
                if (result != null) {
                    callback.onSuccess(result)
                } else callback.onFail(java.lang.IllegalArgumentException("$url result null"))
            } catch (e: Exception) {
                callback.onFail(e)
            }
        }
    }

    interface ApiCallBack {
        fun onSuccess(result: String)
        fun onFail(e: Throwable)
    }

    fun getChapterContentBySync(id: String, label: String): Single<ChapterContentBean> {
        return bookApi3.getChapterContent(jsonOf("id" to id, "label" to label))
    }

    @Deprecated("v3.3.7")
    fun getBySync(url: String): Single<String> {
        val request = Request.Builder().url(url).get().build()
        return Single.create {
            RemoteHelper.simpleOkHttpClient
                    .newCall(request).enqueue(object : Callback {
                        override fun onFailure(call: Call?, e: IOException?) {
                            it.onError(IllegalArgumentException("$url get error"))
                        }

                        override fun onResponse(call: Call?, response: Response?) {
                            if (response == null) {
                                it.onError(IllegalArgumentException("$url get response is null"))
                                return
                            }
                            if (response.isSuccessful) {
                                val resString = response.body()?.string()
                                it.onSuccess(resString ?: "")
                            } else {
                                it.onError(IllegalArgumentException("$url get error"))
                            }
                        }
                    })
        }
    }

    @Throws(IOException::class)
    @WorkerThread
    fun getBySync2(url: String): String? {
        val request = Request.Builder().url(url).get().build()
        val response: Response = RemoteHelper.simpleOkHttpClient.newCall(request).execute()
                ?: return null
        if (response.isSuccessful) {
            return response.body()?.string()
        } else {
            throw IOException("$url get error")
        }
    }

    fun getSearchList(key: String, page: Int, size: Int): Single<List<BookDetailBean>> {
        return bookApi.getSearchList(jsonOf(
                "key" to key,
                "page" to page,
                "size" to size
        )).async()
    }

    fun getSearchHot(): Single<List<String>> {
        return bookApi.getSearchHot(jsonOf()).async()
    }

    fun bindPhone(mobile: String, code: String): Single<LoginRegBean> {
        return bookApi.bindPhone(jsonOf("areacode" to Const.Api.areaCode,
                "mobile" to mobile,
                "code" to code)).async()
    }

    @SuppressLint("CheckResult")
    fun refreshUserInfo(consumer: Consumer<UserInfoBean>? = null) {
        bookApi.refreshUserInfo(jsonOf()).async()
                .subscribe({
                    if (it == null) return@subscribe
                    User.onRefreshUserInfo(it)
                    consumer?.accept(it)
                }, {
                    LogUtils.e("$it")
                })
    }

    fun getAdvStrategy() = bookApi.getAdvStrategy(jsonWithNoTokenOf()).async()

    /*********************************** 第二版接口 *************************************************/

    // 获取任务列表
    fun getMissionList2() = bookApi2.missionList(jsonOf()).async()

    // 签到天数与对应金币的映射列表
    fun getSignGoldList() = bookApi2.signGoldList(jsonOf()).async()

    // 任务上报
    fun missionPost2(task_type: String, reader_time: Long = 0, invi_code: String = "") = bookApi2.missionPost(jsonOf(
            "task_type" to task_type,
            "reader_time" to reader_time,
            "invi_code" to invi_code
    )).async()

    // id为-1代表兑换小说下载
    fun goldExchange(id: String, b_id: String = ""): Completable {
        return bookApi2.goldExchange(jsonOf(
                "id" to id, "b_id" to b_id
        )).async()
    }

    // 获取金币兑换列表
    fun getGoldExchangeList() = bookApi2.goldExchangeList(jsonOf()).async()

    // 获取金币记录
    fun getGoldExchangeRecord(page: Int, size: Int = Paging.limit) = bookApi2.goldRecordList(jsonOf("page" to page, "size" to size)).async()

    // 初始化加载app任务对应次数列表
    fun getMissionInitData() = bookApi2.missionInitData(jsonOf()).async()

    // 邀请详情页面列表
    fun inviteFriendRecord(page: Int, size: Int = Paging.limit) = bookApi2.inviteFriendRecord(jsonOf("page" to page, "size" to size)).async()

    // 编辑用户详情 性别 1:男 2:女 -1:保密
    fun editUser(portrait: String? = null, sex: String? = null, nickName: String? = null): Completable {
//        debug {
        val jo = JSONObject()
        jo.put("token", User.token)
        if (sex != null) {
            jo.put("sex", sex)
        }
        if (nickName != null) {
            jo.put("nickname", nickName)
        }
        val sign = ApiRequestBodyConverter.getSignWithOutUrlEncode(jo)
        LogUtils.e("sign decode" + AES.decrypt(sign))

        var portraitPart: MultipartBody.Part? = null

        if (portrait != null) {
            val portraitFile = File(portrait)
            val requestFile = RequestBody.create(MediaType.parse("image/jpg"), portraitFile)
            portraitPart = MultipartBody.Part.createFormData("portrait", portrait, requestFile)
        }
        return bookApi2.editUserInfo(RequestBody.create(null, sign), portraitPart).async()
    }

    /*********************************** 第三版接口 *************************************************/
    // 获取商品列表
    fun getProductList() = bookApi3.getProductList(jsonOf()).async()

    // 添加书签
    fun addBookmark(bookId: String, label: String, percentage: String, chapterTitle: String): Completable {
        return bookApi3.toggleBookmark(jsonOf("id" to bookId, "label" to label, "percentage" to percentage, "title" to chapterTitle)).async()
    }

    // 删除书签
    fun deleteBookmark(bookId: String, delData: List<BookmarkBean>): Completable {
        val delDataJson = Gson().toJson(delData)
        return bookApi3.toggleBookmark(jsonOf("id" to bookId, "is_del" to "1", "del_data" to delDataJson)).async()
    }

    // 书签列表
    fun getBookmarkList(bookId: String) = bookApi3.getBookmarkList(jsonOf("id" to bookId)).async()

    // 获取支付订单
    fun getPayOrder(productId: String) = bookApi3.getPayOrder(jsonOf("id" to productId)).async()

    // 获取订单列表
    fun getPayLog(page: Int, size: Int = Paging.limit) = bookApi3.getPayLog(jsonOf("page" to page, "size" to size)).async()

    // 获取书城页面信息
    fun getBookMall(gender:Int) = bookApi3.getNewBookMall(jsonOf("gender" to gender)).async()

    // 获取书籍分类列表
    fun getBookCateList() = bookApi3.getBookCateList(jsonOf()).async()

    // 获取首页每日推荐
    fun getTodayRecBook() = bookApi3.getTodayRecBook(jsonOf()).async()

    // 热更/热搜列表
    fun getMoreBookList(type: String, page: Int, size: Int = Paging.limit) = bookApi3.getMoreBookList(jsonOf("type" to type, "page" to page, "size" to size)).async()

    // 广告列表
    fun getAdvList() = bookApi3.getAdvList(jsonOf()).async()

    // 首页弹窗
    fun getOpeningWindow() = bookApi3.getOpeningWindow(jsonOf()).async()

    /*********************************** 第四版接口 *************************************************/

    fun getBookListByGender(gender: String, page: Int, size: Int = Paging.limit) = bookApi3.getBookListByGender(jsonOf("gender" to gender, "page" to page, "size" to size)).async()

    /*********************************** 工具方法 *************************************************/
    // 工具方法，request传值采用@Body注解
    // 所以使用ConverterFactory中的传参
    private fun jsonOf(vararg entries: Pair<String, Any>): String {
        val jo = JSONObject()
        jo.put("token", User.token)
        entries.forEach {
            jo.put(it.first, it.second.toString())
        }
        return jo.toString()
    }

    private fun jsonWithNoTokenOf(vararg entries: Pair<String, Any>): String {
        val jo = JSONObject()
        entries.forEach {
            jo.put(it.first, it.second.toString())
        }
        return jo.toString()
    }
}