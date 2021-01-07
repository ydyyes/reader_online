package com.bule.free.ireader.ui.dialog

import android.app.Activity
import android.app.Dialog
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.Gravity
import android.view.ViewGroup
import com.bule.free.ireader.R
import com.bule.free.ireader.common.utils.KeyboardUtils
import com.bule.free.ireader.common.utils.ToastUtils
import kotlinx.android.synthetic.main.dialog_input.*
import net.yslibrary.android.keyboardvisibilityevent.KeyboardVisibilityEvent


/**
 * Created by suikajy on 2019/4/10
 */
class InputDialog(private val mActivity: Activity,
                  private val block: (String) -> Unit) : Dialog(mActivity, R.style.InputDialog) {

    private val mInput get() = et_input.text.toString().trim()

    companion object {
        fun show(context: Activity, onSendListener: (String) -> Unit) = InputDialog(context, onSendListener).apply { show() }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_input)
        val window = window!!
        window.setGravity(Gravity.BOTTOM)
        //禁用弹出动画，直接显示
        window.setWindowAnimations(0)
        val attributes = window.attributes
        attributes.width = ViewGroup.LayoutParams.MATCH_PARENT
        window.attributes = attributes
        setCanceledOnTouchOutside(true)
        setListener()
    }

    override fun show() {
        super.show()
        et_input.postDelayed({ KeyboardUtils.openSoftKeyboard(et_input) }, 200)
    }

    private fun setListener() {
        KeyboardVisibilityEvent.setEventListener(mActivity) { if (!it) dismiss() }
        btn_ensure.setOnClickListener {
            if (mInput.isEmpty()) {
                ToastUtils.show("输入不能为空")
                return@setOnClickListener
            }
            block(mInput)
            et_input.setText("")
            dismiss()
        }
        et_input.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                val trim = s?.toString()?.trim() ?: ""
                btn_ensure.isEnabled = trim.isNotEmpty()
            }

            override fun afterTextChanged(s: Editable?) {
            }
        })
    }

    override fun onBackPressed() {
        super.onBackPressed()
        mActivity.onBackPressed()
    }
}