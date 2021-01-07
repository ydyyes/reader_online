//Copyright (c) 2017. 章钦豪. All rights reserved.
package com.bule.free.ireader.newbook.adapter;

import android.graphics.Color;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bule.free.ireader.R;
import com.bule.free.ireader.common.utils.LogUtils;
import com.bule.free.ireader.model.bean.BookChapterBean;
import com.bule.free.ireader.newbook.ReadBookConfig;
import com.bule.free.ireader.newbook.widget.ChapterListView;

import java.util.List;


public class ChapterListAdapter extends RecyclerView.Adapter<ChapterListAdapter.Viewholder> {
    public List<BookChapterBean> getBookChapterBeans() {
        return bookChapterBeans;
    }

    public void setBookChapterBeans(List<BookChapterBean> bookChapterBeans) {
        this.bookChapterBeans = bookChapterBeans;
    }

    private List<BookChapterBean> bookChapterBeans;

    public ChapterListView.OnItemClickListener getItemClickListener() {
        return itemClickListener;
    }

    public void setItemClickListener(ChapterListView.OnItemClickListener itemClickListener) {
        this.itemClickListener = itemClickListener;
    }

    private ChapterListView.OnItemClickListener itemClickListener;
    private int index = 0;
    public Boolean isAsc = true;

    public ChapterListAdapter(List<BookChapterBean> bookChapterBeans, @NonNull ChapterListView.OnItemClickListener itemClickListener) {
        this.bookChapterBeans = bookChapterBeans;
        this.itemClickListener = itemClickListener;
    }

    @Override
    public Viewholder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new Viewholder(LayoutInflater.from(parent.getContext()).inflate(R.layout.view_adapter_chapterlist, parent, false));
    }

    @Override
    public void onBindViewHolder(Viewholder holder, final int posiTion) {
        if (bookChapterBeans == null) {
            return;
        }

//        final int realPosition = isReversed? getItemCount()-posiTion-1:posiTion

        if (posiTion == getItemCount() - 1) {
            holder.vLine.setVisibility(View.INVISIBLE);
        } else
            holder.vLine.setVisibility(View.VISIBLE);

        final int position;
        if (isAsc) {
            position = posiTion;
        } else {
            position = getItemCount() - 1 - posiTion;
        }

        //boolean isFree = bookChapterBeans.get(position).isf();

//        if(isFree){
        holder.ivLock.setVisibility(View.GONE);
//        }else{
//            holder.ivLock.setVisibility(View.VISIBLE);
//        }

        holder.tvName.setText(bookChapterBeans.get(position).getTitle());
        holder.flContent.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

//                if(isFree){
//                    setIndex(position);
//                }
                if (position < getItemCount()) {
                    itemClickListener.itemClick(position);
                }
            }
        });
//        LogUtils.e(String.format("position: %s", position));
//        LogUtils.e(String.format("index: %s", index));
        if (position == index) {
            if (ReadBookConfig.INSTANCE.getUiMode() == ReadBookConfig.UIMode.DAY) {
                holder.flContent.setBackgroundColor(Color.parseColor("#cfcfcf"));
            } else {
                holder.flContent.setBackgroundColor(Color.parseColor("#1b1b1b"));
            }
            holder.flContent.setClickable(false);
            holder.flContent.setSelected(true);
        } else {
            holder.flContent.setBackgroundResource(R.drawable.bg_ib_pre2);
            holder.flContent.setClickable(true);
            holder.flContent.setSelected(false);
        }
    }

    @Override
    public int getItemCount() {
        if (bookChapterBeans == null)
            return 0;
        else
            return bookChapterBeans.size();
    }

    public class Viewholder extends RecyclerView.ViewHolder {
        private LinearLayout flContent;
        private TextView tvName;
        private View vLine;
        private ImageView ivLock;

        public Viewholder(View itemView) {
            super(itemView);
            flContent = (LinearLayout) itemView.findViewById(R.id.fl_content);
            tvName = (TextView) itemView.findViewById(R.id.tv_name);
            vLine = itemView.findViewById(R.id.v_line);
            ivLock = (ImageView) itemView.findViewById(R.id.iv_chapter_lock);
        }
    }

    // 逆序，返回true表示已经逆序
    public boolean reverseOrder() {
        if (bookChapterBeans != null && !bookChapterBeans.isEmpty()) {
//            Collections.reverse(bookChapterBeans);
            isAsc = false;
            notifyDataSetChanged();
        }
        return !isAsc;
    }

    // 正序，返回false表示已经正序
    public boolean normalOrder() {
        if (!isAsc) {
            //Collections.reverse(bookChapterBeans);
            isAsc = true;
            notifyDataSetChanged();
        }
        return !isAsc;
    }

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        LogUtils.e("set index " + index + ", old index is " + this.index);
//        notifyItemChanged(this.index);
        this.index = index;
////        notifyItemChanged(this.index);
        notifyDataSetChanged();
    }
}
