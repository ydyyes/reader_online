package com.bule.free.ireader.module.setting

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import com.bule.free.ireader.Const
import com.bule.free.ireader.R
import com.bule.free.ireader.api.Api
import com.bule.free.ireader.common.library.glide.load
import com.bule.free.ireader.common.utils.*
import com.bule.free.ireader.model.User
import com.bule.free.ireader.model.UserInfoRefreshEvent
import com.bule.free.ireader.ui.base.BaseActivity2
import com.bule.free.ireader.ui.dialog.InputDialog
import com.luck.picture.lib.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.PictureMimeType
import kotlinx.android.synthetic.main.activity_user_setting.*

/**
 * Created by suikajy on 2019/4/15
 */
class UserSettingActivity : BaseActivity2() {

    companion object {
        fun start(activity: Activity) {
            val intent = Intent(activity, UserSettingActivity::class.java)
            activity.startActivity(intent)
        }
    }

    override val layoutId: Int
        get() = R.layout.activity_user_setting

    override fun init() {
        refreshView()
    }

    override fun setListener() {
        subscribeEvent(UserInfoRefreshEvent::class.java) { refreshView() }
        btn_user_gender.onClick {
            var finalGender: Const.Gender = User.gender
            AlertDialog.Builder(this)
                    .setCancelable(false)
                    .setSingleChoiceItems(Res.stringArray(R.array.setting_dialog_gender), User.gender.ordinal) { dialog, which ->
                        finalGender = Const.Gender.values()[which]
                    }.setPositiveButton("确定") { dialog, which ->
                        val apiParam = if (finalGender == Const.Gender.NONE) "-1" else finalGender.apiParam.toString()
                        Api.editUser(sex = apiParam).go {
                            LogUtils.e("finalGender: $finalGender")
                            User.gender = finalGender
                            RxBus.post(UserInfoRefreshEvent)
                        }
                        dialog.dismiss()
                    }.create().show()
        }
        btn_user_nickname.onClick {
            InputDialog.show(this) { input ->
                if (input.isEmpty()) {
                    ToastUtils.show("用户昵称不能为空")
                    return@show
                }
                if (input.length > 7) {
                    ToastUtils.show("昵称长度不能超过7个字符")
                    return@show
                }
                Api.editUser(nickName = input).go {
                    User.nickName = input
                    RxBus.post(UserInfoRefreshEvent)
                }
            }
        }
        btn_user_avatar.onClick {
            ToastUtils.show("开发中，暂未开放")
//            PictureSelector.create(this)
//                    .openGallery(PictureMimeType.ofImage())
////                    .theme(R.style.picture_white_style)
//                    .selectionMode(PictureConfig.SINGLE)
//                    .imageSpanCount(4)
//                    .minSelectNum(1)
//                    .previewImage(true)
//                    .compress(true)
//                    .isCamera(false)
//                    .enableCrop(false)
//                    .synOrAsy(false)
//                    .glideOverride(160, 160)
//                    .circleDimmedLayer(true)
//                    .isGif(false)
//                    .rotateEnabled(false)
//                    .showCropFrame(false)// 是否显示裁剪矩形边框 圆形裁剪时建议设为false
//                    .showCropGrid(false)
//                    .withAspectRatio(1, 1)
//                    .hideBottomControls(true)
//                    .openClickSound(false)
//                    .minimumCompressSize(400)
//                    .forResult(PictureConfig.CHOOSE_REQUEST)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                PictureConfig.CHOOSE_REQUEST -> {
                    // 图片选择结果回调
                    val selectList = PictureSelector.obtainMultipleResult(data)
                    if (selectList.isNotEmpty()) {
                        Api.editUser(portrait = selectList[0].compressPath).go {
                            User.syncToServer()
                        }
                    }
                }
            }
        }
    }

    private fun refreshView() {
        tv_gender.text = User.gender.text
        tv_user_name.text = User.nickName
        if (User.avatarUrl.isEmpty()) {
            iv_avatar.load(R.drawable.person_ic_avatar_def)
        } else {
            iv_avatar.load(R.drawable.person_ic_avatar_def)
            //iv_avatar.load(User.avatarUrl)
        }
    }

}