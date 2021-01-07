package com.bule.free.ireader.model.bean;


import java.util.List;

public class AdsInfo {

    private Strategy strategy;
    private List<AdsInfoItem> data;

    public void setStrategy(Strategy strategy) {
        this.strategy = strategy;
    }

    public void setData(List<AdsInfoItem> data) {
        this.data = data;
    }

    public Strategy getStrategy() {
        return strategy;
    }

    public List<AdsInfoItem> getData() {
        return data;
    }

    public class Strategy {
        private int ad_show_times_everyday;
        private int ad_show_intv;

        public int getAd_show_times_everyday() {
            return ad_show_times_everyday;
        }

        public int getAd_show_intv() {
            return ad_show_intv;
        }

        public void setAd_show_times_everyday(int ad_show_times_everyday) {
            this.ad_show_times_everyday = ad_show_times_everyday;
        }

        public void setAd_show_intv(int ad_show_intv) {
            this.ad_show_intv = ad_show_intv;
        }
    }

    public class AdsInfoItem {

        private String id;
        private String title;
        private String link;
        private String location;
        private String img;

        private int ad_show_times_everyday;
        private int ad_show_intv;

        public String getId() {
            return id;
        }

        public void setId(String id) {
            this.id = id;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getLink() {
            return link;
        }

        public void setLink(String link) {
            this.link = link;
        }

        public String getLocation() {
            return location;
        }

        public void setLocation(String location) {
            this.location = location;
        }

        public String getImg() {
            return img;
        }

        public void setImg(String img) {
            this.img = img;
        }

        public int getAd_show_times_everyday() {
            return ad_show_times_everyday;
        }

        public void setAd_show_times_everyday(int ad_show_times_everyday) {
            this.ad_show_times_everyday = ad_show_times_everyday;
        }

        public int getAd_show_intv() {
            return ad_show_intv;
        }

        public void setAd_show_intv(int ad_show_intv) {
            this.ad_show_intv = ad_show_intv;
        }
    }
}
