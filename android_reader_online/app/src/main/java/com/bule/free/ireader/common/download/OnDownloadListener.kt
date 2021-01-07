package com.bule.free.ireader.common.download

import com.bule.free.ireader.model.objectbox.bean.DownloadTaskBean

/**
 * Created by suikajy on 2019/3/14
 */
interface OnDownloadListener {
    /**
     * @param pos    : Task在item中的位置
     * @param status : Task的状态
     * @param msg:   传送的Msg
     */
    fun onDownloadChange(pos: Int, status: Int, msg: String)

    /**
     * 回复
     */
    fun onDownloadResponse(pos: Int, status: Int)

    fun onDownloadChange(task: DownloadTaskBean)
}