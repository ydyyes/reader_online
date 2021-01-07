package com.bule.free.ireader.main.fragment

import android.annotation.SuppressLint
import android.support.v7.widget.GridLayoutManager
import android.support.v7.widget.LinearLayoutManager
import android.support.v7.widget.RecyclerView
import android.support.v7.widget.RecyclerView.SCROLL_STATE_IDLE
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.adv.CachedAdvInfo
import com.bule.free.ireader.common.adv.tuia.TuiaDobberAdvDel
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.common.widget.CommDialog
import com.bule.free.ireader.common.widget.adapter.WholeAdapter
import com.bule.free.ireader.main.MainActivity
import com.bule.free.ireader.model.*
import com.bule.free.ireader.model.bean.BookCollItemBean
import com.bule.free.ireader.model.local.DatabaseUtils
import com.bule.free.ireader.model.objectbox.OB
import com.bule.free.ireader.model.objectbox.bean.BookBean
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean
import com.bule.free.ireader.model.objectbox.bean.BookHistoryBean_
import com.bule.free.ireader.model.objectbox.boxOf
import com.bule.free.ireader.newbook.ui.NewReadBookActivity
import com.bule.free.ireader.presenter.BookShelfPresenter
import com.bule.free.ireader.presenter.contract.BookShelfContract
import com.bule.free.ireader.ui.activity.BookDetailActivity
import com.bule.free.ireader.ui.activity.WebAdsActivity
import com.bule.free.ireader.ui.activity.WebViewActivity
import com.bule.free.ireader.ui.adapter.CollBookAdapter
import com.bule.free.ireader.ui.adapter.ListCollBookAdapter
import com.bule.free.ireader.ui.adapter.view.CollBookHolder
import com.bule.free.ireader.ui.base.BaseMVPFragment
import com.umeng.analytics.MobclickAgent
import kotlinx.android.synthetic.main.fragment_bookshelf.*

/**
 * Created by suikajy on 2019/2/26
 */
class BookShelfFragment : BaseMVPFragment<BookShelfContract.Presenter>(), BookShelfContract.View {

    companion object {
        const val SPAN_COUNT = 3
    }

    override fun bindPresenter() = BookShelfPresenter()

    override fun showError() {
    }

    private val mCollBookAdapter by lazy { CollBookAdapter() }
    private val mListCollBookAdapter by lazy { ListCollBookAdapter() }
    private val mHeader by lazy { HeaderItemView() }
    private lateinit var mLinearLayoutManager: LinearLayoutManager
    private lateinit var mGridLayoutManager: GridLayoutManager

    private var mFloatAdvBean: AdvListBean? = null
//    private val tuiaDobberAdvDel by lazy {
//        TuiaDobberAdvDel(tuia_float_view)
//    }

    override fun getContentId() = R.layout.fragment_bookshelf

    override fun processLogic() {
        super.processLogic()

        setUpAdapter()

        book_shelf_rv_content.startRefresh()

        if (User.isFirstLoadRemoteBook) {
            mPresenter.refreshRemoteBooks()
        } else {
            mPresenter.refreshLocalBooks()
        }

        MobclickAgent.onEvent(activity, "book_shelf_fragment", "book_shelf")
        //tuia_float_view.post { tuiaDobberAdvDel.load() }
        iv_float_adv.visibility = View.GONE
        val floatAdvList = CachedAdvInfo.getFloatAdvList()
        if (floatAdvList.isNotEmpty()) {
            mFloatAdvBean = floatAdvList[0]
            mFloatAdvBean?.let { bean ->
                iv_float_adv.visibility = View.VISIBLE
                iv_float_adv.load(bean.cover)
            }
        }

        setListener()
        book_shelf_rv_content.post(this::refreshHeader)
    }

    private fun setUpAdapter() {
        mLinearLayoutManager = LinearLayoutManager(activity!!)
        mGridLayoutManager = GridLayoutManager(activity!!, SPAN_COUNT)
        mCollBookAdapter.addHeaderView(mHeader)
        mListCollBookAdapter.addHeaderView(mHeader)

        refreshList(null)
    }

    private fun setListener() {
        val recommendDisp = RxBus.toObservable(RefreshBookShelfEvent::class.java)
                .subscribe {
                    mPresenter.refreshLocalBooks()
                }
        RxBus.toObservable(this, AddBookToShelfEvent::class.java) { mPresenter.refreshLocalBooks() }
        addDisposable(recommendDisp)
        RxBus.toObservable(this, ChangeShelfModeEvent::class.java) {
            mPresenter.refreshLocalBooks()
        }
        RxBus.toObservable(this, UserInfoRefreshEvent::class.java) { mHeader.refreshSignedStatus() }
        book_shelf_rv_content.setOnRefreshListener {
            mPresenter.refreshLocalBooks()
            refreshHeader()
        }
        iv_float_adv.onSafeClick {
            mFloatAdvBean?.let { bean -> WebViewActivity.start(bean.link) }
        }

        mCollBookAdapter.setOnItemClickListener { view, pos ->
            //LogUtils.e("图墙item点击：$view $pos")
            val bookDetailBean = mCollBookAdapter.getItem(pos)
            when (bookDetailBean.id) {
                CollBookHolder.ADD_BUTTON_ID -> RxBus.post(ToBookShelfEvent)
                CollBookHolder.ADV_BUTTON_ID -> if (bookDetailBean.link.isNotEmpty()) {
                    WebViewUtils.startBrowser(activity,bookDetailBean.link)
                   //WebViewActivity.start(bookDetailBean.link)
                }
                else -> {
                    if (bookDetailBean.isNewChapter) {
                        bookDetailBean.isNewChapter = false
                        OB.boxStore.boxFor(BookBean::class.java).put(bookDetailBean)
                    }
                    //LogUtils.e("刷新图墙列表")
                    mCollBookAdapter.notifyDataSetChanged()
                    startReadBook(bookDetailBean)
                }
            }
        }

        mCollBookAdapter.setOnItemLongClickListener { _, pos ->
            LogUtils.e("图墙item长点击：$pos")
            val item = mCollBookAdapter.getItem(pos)
            if (item.id != CollBookHolder.ADD_BUTTON_ID) openItemDialog(item)
            return@setOnItemLongClickListener false
        }

        mListCollBookAdapter.setOnItemClickListener { _, pos ->
            LogUtils.e("列表item点击：$pos")
            val bookDetailBean = mListCollBookAdapter.getItem(pos)
            when (bookDetailBean.id) {
                CollBookHolder.ADD_BUTTON_ID -> RxBus.post(ToBookShelfEvent)
                CollBookHolder.ADV_BUTTON_ID -> if (bookDetailBean.link.isNotEmpty()) WebViewActivity.start(bookDetailBean.link)
                else -> {
                    if (bookDetailBean.isNewChapter) {
                        bookDetailBean.isNewChapter = false
                        OB.boxStore.boxFor(BookBean::class.java).put(bookDetailBean)
                    }
                    //LogUtils.e("刷新图墙列表")
                    mListCollBookAdapter.notifyDataSetChanged()
                    startReadBook(bookDetailBean)
                }
            }
        }

        mListCollBookAdapter.setOnItemLongClickListener { _, pos ->
            LogUtils.e("列表item长点击：$pos")
            val item = mListCollBookAdapter.getItem(pos)
            if (item.id != CollBookHolder.ADD_BUTTON_ID) openItemDialog(item)
            return@setOnItemLongClickListener false
        }

        book_shelf_rv_content.recyclerView.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView?, newState: Int) {
//                if (newState == SCROLL_STATE_IDLE) {
//                    tuiaDobberAdvDel.show()
//                } else {
//                    tuiaDobberAdvDel.hide()
//                }
                if (mFloatAdvBean != null) {
                    if (newState == SCROLL_STATE_IDLE) {
                        iv_float_adv.visibility = View.VISIBLE
                    } else {
                        iv_float_adv.visibility = View.GONE
                    }
                }

            }
        })
    }

    // 如果collBookBeans是空则代表更改界面模式
    private fun refreshList(collBookBeans: MutableList<BookBean>?) {
        if (Config.isShelfMode.not()) { //列表模式
            if (book_shelf_rv_content.recyclerView.layoutManager !== mLinearLayoutManager) {
                book_shelf_rv_content.setLayoutManager(mLinearLayoutManager)
                book_shelf_rv_content.setAdapter(mListCollBookAdapter)
//                mHeader.refresh()
            }
            if (collBookBeans != null) {
                mListCollBookAdapter.refreshItems(collBookBeans)
            }
        } else { // 书架模式
            if (book_shelf_rv_content.recyclerView.layoutManager !== mGridLayoutManager) {
                book_shelf_rv_content.setLayoutManager(mGridLayoutManager)
                book_shelf_rv_content.setAdapter(mCollBookAdapter)
//                mHeader.refresh()
            }
            if (collBookBeans != null) {
                mCollBookAdapter.refreshItems(collBookBeans)
            }
        }
    }

    private fun openItemDialog(collBook: BookBean) {
        CommDialog(context!!).apply {
            setCancelable(false)
            setOkClick { _, _ -> mPresenter.delBookShelf(collBook) }
            show()
            setTitle("确认删除")
            setContent("确定要删除掉这1本书吗？")
        }
    }

    override fun finishRemoteBooks(collBookBeans: MutableList<BookBean>?) {
        if (collBookBeans != null) {
            LogUtils.e("finishRemoteBooks")
            val bookAdvList = CachedAdvInfo.getBookAdvList()
            LogUtils.e("bookAdvList: $bookAdvList")
            for (bookAdv in bookAdvList) {
                val advButtonBean = BookBean()
                advButtonBean.title = bookAdv.title
                advButtonBean.author = ""
                advButtonBean.id = CollBookHolder.ADV_BUTTON_ID
                advButtonBean.link = bookAdv.link
                advButtonBean.cover = bookAdv.cover
                collBookBeans.add(advButtonBean)
            }

            val addButtonBean = BookBean()
            addButtonBean.id = CollBookHolder.ADD_BUTTON_ID
            collBookBeans.add(addButtonBean)

            refreshList(collBookBeans)
            //mCollBookAdapter.refreshItems(collBookBeans)

            User.isFirstLoadRemoteBook = false
        }
    }

    override fun finishLocalBooks(collBookBeans: MutableList<BookBean>?) {
        if (collBookBeans != null) {
            val bookAdvList = CachedAdvInfo.getBookAdvList()
            LogUtils.e("bookAdvList: $bookAdvList")
            for (bookAdv in bookAdvList) {
                val advButtonBean = BookBean()
                advButtonBean.title = bookAdv.title
                advButtonBean.author = ""
                advButtonBean.id = CollBookHolder.ADV_BUTTON_ID
                advButtonBean.link = bookAdv.link
                advButtonBean.cover = bookAdv.cover
                //collBookBeans.add(advButtonBean)
                collBookBeans.add(0,advButtonBean);
            }
            val bean = BookBean()
            bean.id = CollBookHolder.ADD_BUTTON_ID
            collBookBeans.add(bean)
            MobclickAgent.onEvent(activity, "shelf_book_count", collBookBeans.size.toString())
            refreshList(collBookBeans)
            //mCollBookAdapter.refreshItems(collBookBeans)

            mPresenter.updateLocalBooks(mCollBookAdapter.items)
            safeTime = System.currentTimeMillis()
        }
    }

    override fun finishUpdateBook() {
        safeNotifyDataSetChanged()
    }

    private var safeTime = 0L

    private fun safeNotifyDataSetChanged() {

        if (Config.isShelfMode) {
            LogUtils.e("刷新完毕，更新图墙列表notify")
            mCollBookAdapter.notifyDataSetChanged()
        } else {
            LogUtils.e("刷新完毕，更新列表item notify")
            mListCollBookAdapter.notifyDataSetChanged()
        }

    }

    override fun showErrorTip(error: String?) {
        book_shelf_rv_content.setTip(error)
        book_shelf_rv_content.showTip()
    }

    override fun finishDelBook() {
        LogUtils.d("finishDelBook")
        mPresenter.refreshLocalBooks()
    }

    override fun complete() {
        book_shelf_rv_content.finishRefresh()
    }

    // 刷新每日推荐部分
    private fun refreshHeader() {
        Api.getTodayRecBook().go(this) {
            mHeader.refresh(it)
        }
    }

    // 开启读书界面，先记录到阅读历史里面
    private fun startReadBook(bookCollItemBean: BookBean) {
        var bookHistoryBean = boxOf(BookHistoryBean::class.java).query().equal(BookHistoryBean_.bookId, bookCollItemBean.id).build().findUnique()
        if (bookHistoryBean == null) {
            bookHistoryBean = BookHistoryBean(bookCollItemBean.id, bookCollItemBean.cover, bookCollItemBean.author,
                    bookCollItemBean.majorCate, bookCollItemBean.longIntro, System.currentTimeMillis(), bookCollItemBean.title)
        } else {
            bookHistoryBean.addTime = System.currentTimeMillis()
        }
        NewReadBookActivity.startActivityAndLog(activity, bookHistoryBean)
    }

    @SuppressLint("SetTextI18n")
    inner class HeaderItemView : WholeAdapter.ItemView {

        private var mHeaderVH: HeaderViewHolder? = null
        private var mBean: TodayRecBookBean? = null

        fun refresh(recBean: TodayRecBookBean? = null) {
            //LogUtils.e("recBean: $recBean")
            if (mHeaderVH == null) return
            if (recBean != null) {
                mBean = recBean
                mHeaderVH!!.mTvBookTitle.text = recBean.title
                LogUtils.e("recBean: ${recBean}")
                mHeaderVH!!.mIvRecBookCover.load(recBean.cover)
                mHeaderVH!!.mTvRecBookAuthorAndType.text = "${recBean.author} | ${recBean.majorCate}"
                mHeaderVH!!.mTvRecBookDes.text = recBean.longIntro
                mHeaderVH!!.mBtnRecBook.setOnClickListener { BookDetailActivity.start(activity!!, recBean.id, false) }
            } else if (mBean != null) {
                mHeaderVH!!.mTvBookTitle.text = mBean!!.title
                mHeaderVH!!.mIvRecBookCover.load(mBean!!.cover)
                mHeaderVH!!.mTvRecBookAuthorAndType.text = "${mBean!!.author} | ${mBean!!.majorCate}"
                mHeaderVH!!.mTvRecBookDes.text = mBean!!.longIntro
                mHeaderVH!!.mBtnRecBook.setOnClickListener { BookDetailActivity.start(activity!!, mBean!!.id, false) }
            } else {
                mHeaderVH!!.mBtnRecBook.setOnClickListener(null)
            }
            refreshSignedStatus()
            val notifyContent = ApiConfig.contact_us
            if (notifyContent.isEmpty()) {
                mHeaderVH!!.mLayoutNotify.visibility = View.GONE
            } else {
                mHeaderVH!!.mLayoutNotify.visibility = View.VISIBLE
                mHeaderVH!!.mTvNotify.text = notifyContent
            }
        }

        fun refreshSignedStatus() {
            mHeaderVH!!.mTvSignedDayCount.text = "${User.signedDaysCount}天"
            if (User.todayIsSigned) {
                mHeaderVH!!.mBtnSign.setOnClickListener { RxBus.post(MainActivityChangePageEvent(MainActivity.Page.WELFARE)) }
                mHeaderVH!!.mBtnSign.isSelected = true
                mHeaderVH!!.mBtnSign.text = "已签到"
            } else {
                mHeaderVH!!.mBtnSign.isSelected = false
                mHeaderVH!!.mBtnSign.text = "签到"
                mHeaderVH!!.mBtnSign.setOnClickListener {
                    RxBus.post(SignEvent)
                    RxBus.post(MainActivityChangePageEvent(MainActivity.Page.WELFARE))
                }
            }
        }

        override fun onCreateView(parent: ViewGroup?): View {
            val view = layoutInflater.inflate(R.layout.header_book_shelf, parent, false)
            mHeaderVH = HeaderViewHolder(view)
            return view
        }

        override fun onBindView(view: View?) {
            //LogUtils.e("onBindView()")
            refresh()
        }
    }

    private class HeaderViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val mIvRecBookCover: ImageView by bindView(R.id.iv_rec_book_cover)
        val mTvBookTitle: TextView by bindView(R.id.tv_book_title)
        val mTvRecBookAuthorAndType: TextView by bindView(R.id.tv_rec_book_author_and_type)
        val mTvRecBookDes: TextView by bindView(R.id.tv_rec_book_des)
        val mTvSignedDayCount: TextView by bindView(R.id.tv_signed_day_count)
        val mBtnSign: TextView by bindView(R.id.btn_sign)
        val mTvNotify: TextView by bindView(R.id.tv_notify)
        val mLayoutNotify: LinearLayout by bindView(R.id.layout_notify)
        val mBtnRecBook: View by bindView(R.id.btn_rec_book)
    }
}