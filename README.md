# reader_online
online reader  contain server(php),android client ,apple client;
具体分为三个项目：
1. android_reader_online 安卓端
2.ios_reader_online  苹果端
3.php_reader_online  php服务器端对应客户端接口及后台功能

项目部署源码有具体部署文档，请查看二级reader;

下面是主要的接口文档（有可能会有些小差别）：

[Toc]
通用参数：imei、imsi、uuid、其他一些设备信息

|字段|说明
|--|--|
|imei|	用户设备的imei， 可能为空| 
|imsi| 用户Sim 卡的 序列号， 可能为空|
|uuid|生成的UUid|
|vcode|apk的版本号||
|vname| apk的版本名|
|model|设备型号||
|manuFacturer|设备制造商 |
|brand|设备品牌|
resolution|设备的宽x高|
|sdk|系统版本|
|channel|渠道号|
|net|网络类型|

*****

*****
******
~~~
~~~
'0'      =>'操作成功',
'200'    =>'操作成功',
'2001'   =>'操作失败',
'300100' =>'用户唯一标识别为空',
'300101' =>'请求类型不正确',
'300102' =>'操作失败请稍后重试',
'300103' =>'登陆失败',
'300104' =>'手机号未绑定或者输入有误',
'300105' => '密码格式错误,只含有数字、字母、下划线,6-15位',
'300106' => '俩次输入不一致',
'300107' => '手机号已经被绑定',
'300108' => 'Token失效或者不存在',
'300109' => '该用户已经绑定过手机号或者该手机号已经绑定',
'300110' => '登录设备过多',
'400100' =>' 参数错误',
'400101' => '参数不能为空',
'400102' => '手机号格式不正确',
'400103' => 'ID必须为正整数',
'400104' => '数据不存在或者已经下架',
'400105' => '该栏目不存在或者已经下架',
'400106' => '没有数据',
'400108' => '没有找到章节列表',
'400107' => '已经添加了,不能重复添加',
'400109' => '内容长度不能低于10或者超过200',
'400110' => '验证码发送次数超限',
'400111' => '验证码错误',
'400112' => '频繁发送验证码',
'600101' => '订单创建失败',
'500101' => 'sign不成功'
~~~
~~~
---
### 获取服务器时间：
      
 - 请求方式： GET
 - 请求地址：http://172.16.2.160:9000/GetTime/1

``` 
1550820571209
```
> token:token
> u_type:用户类型
> expire:有无会员，如果有会员会显示到期时间戳,没有或者到期显示为0

---

*****
********
---
### 1、用户登陆注册接口：
      
 - 请求方式： POST
 - 请求地址： http://172.16.2.160:9000/ApinRegist/1
 - 请求参数： sign=密文参数
 - 业务请求参数
 
	- mobile     string  手机号码，短信通道往此手机发送验证码 （type为2,必填）
        - code        string  验证码  (type为2,必填）
        - areacode string  区号  (type为2,必填）例如 +86
 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": {
        "token": "9uaf7ffc2a629a1c258336fde8a1f71e0a15c6d071a2a180",
        "u_type": "游客",
        "gold": "0",
        "expire": "0",
        "uni_id":"2c1e21e73d30a8de8e7bb1a69d5f06c81Zjm"，
        "invitation_code" ： "SDWS44",
        "reader_time" : "123456"
    }
}
```
> token:token
> u_type:用户类型
> gold:金币数量
> expire:有无会员，如果有会员会显示到期时间戳,没有或者到期显示为0
>  uni_id  :用户独一无二的ID
>invitation_code：邀请码
>reader_time:用户阅读时长 时间单位 秒


---

*****
---
### 2、获取分类数据：
      
 - 请求方式： POST
 - 请求地址： http://172.16.2.160:9000/Cate/1
 - 请求参数： sign=密文参数
 - 业务请求参数


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        {
            "id": "9",
            "name": "乡村风情"
        },
        {
            "id": "10",
            "name": "武侠玄幻"
        }
    ]
}
```
> id:分类id
> name:分类名称

---
---
### 3、获取轮播图接口：
      
 - 请求方式： POST
 - 请求地址： http://172.16.2.160:9000/Banners/1
 - 请求参数： sign=密文参数
 - 业务请求参数
 - 响应数据格式： json
 - 明文返回值如下：
``` json
~~~
{
    "errorno": 200,
    "msg": "操作成功"
    "data": [
      {
        "id": "4",                     #轮播图id
        "name": "test",             #轮播图名称
        "fid": "1",                        #小说ID
        "inner"  "0"      0  不是内部链接     1 福利中心 2 兑换金币 3 邀请好友   
        "img": "http://xiaoshuo.enjoynut.cn/Uploads/xiaoshuo/28/30/c22d599d1cbc.png",                            #轮播图图片
        "_id": "1fb52965b3af8e431578f16d6c31a5d5",  
       "type":"book"
      },
      {
        "id": "3",                    #轮播图id
        "name": "sss",        #轮播图名称
        "fid": "1",                    #广告ID
        "inner"  "1"      0  不是内部链接     1 福利中心 2 兑换金币 3 邀请好友  
        "img": "http://xiaoshuo.enjoynut.cn/Uploads/xiaoshuo/ca/29/52fa5b6b6bb8.png",                                #轮播图图片
        "title": "guanggao",        #广告名称
        "link": "http://www.tencent.com",     #广告链接
        "location": "1",                   #广告位置 1开屏；2文章末尾
        "cover": "http://xiaoshuo.enjoynut.cn/Uploads/xiaoshuo/ca/29/52fa5b6b6bb8.png",                                      #广告图片
        "update": "2018-12-26",     #广告更新于
       "type":"ad"
      }， 
    ]
}

~~~
```
---

---
### 4、获取书城接口：
      
 - 请求方式： POST
 - 请求地址： http://172.16.2.160:9000/Novel/1
 - 请求参数： sign=密文参数
 - 业务请求参数
  
        - m_id    int  左侧分类的id   （如果不传默认全部）
        - type    string  上传分类的name  参数值 hot new reputation over,对应 新书 热门 口碑 完结 默认new    （如果不传默认全部）
        - page    int  第几页,默认为1
        - size    int   每页显示，默认为6
 
        注：m_id,type传一个或者不传
        

 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        {
            "id": "4",
            "title": "213",
            "cover": "http://172.16.2.161:9000/Uploads/xiaoshuo/c0/0d/3829e36c7146.png",
            "author": "温泉1",
            "longIntro": "温泉2",
            "wordCount": "123",
            "gender": "2",
            "over": "1",
            "score": "2.1",
            "serializeWordCount": "123321",
            "latelyFollower": "123",
            "retentionRatio": "22.23",
            "tags": "123,312",
            "isfree": "1",
            "majorCate": "9",
            "lastChapter": "1000",
            "updated": "0"
        },
        {
            "id": "3",
            "title": "温泉",
            "cover": "http://172.16.2.161:9000/Uploads/xiaoshuo/ff/26/0e01e56386f3.png",
            "author": "温泉1",
            "longIntro": "温泉2",
            "wordCount": "112",
            "gender": "2",
            "over": "1",
            "score": "3.2",
            "serializeWordCount": "123321",
            "latelyFollower": "123",
            "retentionRatio": "11.22",
            "tags": "123,312",
            "isfree": "1",
            "majorCate": "10",
            "lastChapter": "1231",
            "updated": "1551171508"
        }
    ]
}
```
> id:id
> titile:名称  
> author:作者
> cover :封面
> cates  分类
> longIntro 描述
> latelyFollower 追书人数
> retentionRatio 留存率
> serializeWordCount 日更新字数
> label 标签
> wordCount 本书字数
> score 评分
> isfree:是否免费 1,是 0 不是
> over  是否完结 1完结 0 没有完结
> lastChapter  最后一章节
> updated  最后书籍时间
> 

---

---
### 5、获取书籍详情：
      
 - 请求方式： POST
 - 请求地址： http://172.16.2.160:9000/Detail/1
 - 请求参数： sign=密文参数
 - 业务请求参数

        - id    int  小说ID  （如果不传默认全部）
 
        注：此接口会根据用户的channel 下发推荐书本,如果 channel没有的话,会默认下发全部
        

 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": {
        "detail": {
            "id": "4",
            "title": "213",
            "cover": "http://172.16.2.160:9000/Uploads/xiaoshuo/c0/0d/3829e36c7146.png",
            "author": "温泉1",
            "longIntro": "温泉2",
            "wordCount": "123",
            "gender": "2",
            "over": "1",
            "score": "2",
            "serializeWordCount": "123321",
            "latelyFollower": "123",
            "retentionRatio": "22.23",
            "tags": [
                "123",
                "312"
            ],
            "isfree": "1",
            "majorCate": "9",
            "lastChapter": "1000",
            "updated": "1551258987",
            "cates": "乡村风情"
        },
        "recommend": [
            {
                "id": "3",
                "title": "温泉",
                "cover": "xiaoshuo/ff/26/0e01e56386f3.png",
                "author": "温泉1",
                "longIntro": "温泉2",
                "wordCount": "112",
                "gender": "2",
                "over": "1",
                "score": "3.2",
                "serializeWordCount": "123321",
                "latelyFollower": "123",
                "retentionRatio": "11.22",
                "tags": "123,312",
                "isfree": "1",
                "majorCate": "10",
                "lastChapter": "1231",
                "updated": "1551171508"
            },
            {
                "id": "4",
                "title": "213",
                "cover": "xiaoshuo/c0/0d/3829e36c7146.png",
                "author": "温泉1",
                "longIntro": "温泉2",
                "wordCount": "123",
                "gender": "2",
                "over": "1",
                "score": "2.1",
                "serializeWordCount": "123321",
                "latelyFollower": "123",
                "retentionRatio": "22.23",
                "tags": "123,312",
                "isfree": "1",
                "majorCate": "9",
                "lastChapter": "1000",
                "updated": "1551258987"
            }
        ]
    }
}
```
detail:详解内容   recommend:推荐内容
> id:id
> titile:名称  
> author:作者
> cover :封面
> cates  分类
> longIntro 描述
> latelyFollower 追书人数
> retentionRatio 留存率
> serializeWordCount 日更新字数
> label 标签
> wordCount 本书字数
> score 评分
> isfree:是否免费 1,是 0 不是
> over  是否完结 1完结 0 没有完结
> lastChapter  最后一章节
> updated  最后书籍时间
> 

---

---
### 6、获取书的章节：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.160:9000/ChapterLt/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - id         int 书ID


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        {
            "title": "蓝星某个城市内，一个略显颓废的青年，他的双目无神，神情疲惫的走在马路上，给人一种随时可能逝去的苍凉之感。",
            "label": "93"
        },
        {
            "title": "无尽混沌的中央，屹立着一株三十六品混沌白莲，白莲的莲蓬上生长着十枚莲子，莲子九小一大。",
            "label": "104"
        },
      ]
      
  
}
```
> title:标题
> label:标记
 注: 按顺序返回的章节
---
---
### 7、章节内容接口：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.160:9000/ChapterIn/1
 - 请求参数： sign=密文参数
 - 业务请求参数
      
        - id         int 书ID
        - label      int   标记


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": {
        "url": "http://172.16.2.160:9000/Uploads/admin_txt/3/102_8ecd04ae441ba801078ce99fd4423dd5.txt"
    }
}
```
> url:内容所在地址
---
---
### 8、发送短信接口：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.160:9000/sms/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - areacode   stirng      区号 例如 +86
        - mobile      int   手机号码


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": []
}
```
---
### 9、绑定手机号：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.160:9000/Bindph/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - areacode  stirng      区号 例如 +86
        - mobile     int   手机号码
        - code        int   验证码
        - token      token


 - 响应数据格式： json
 - 明文返回值如下：
{
    "errorno": 200,
    "msg": "操作成功",
    "data": {
            "token": "9uaf7ffc2a629a1c258336fde8a1f71e0a15c6d071a2a180",
            "u_type": "游客",
            "gold": "金币"，
            "expire": "0",
            "uni_id":"2c1e21e73d30a8de8e7bb1a69d5f06c81Zjm"
             }
}
---
> token:token
> u_type:用户类型
> gold:金币数量
> expire:有无会员，如果有会员会显示到期时间戳,没有或者到期显示为0
>  uni_id  :用户独一无二的ID
> nickname :昵称
> sex 性别 1男 2女 -1 保密
> cover 头像地址

---
### 10、用户反馈接口：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.160:9000/Feecba/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - file     string    图片上传字段（不用加入sign,直接用post提交）
        - content       string 反馈的内容不能低于10或者超过200的长度
        - email      string  邮箱地址    
        - token      token


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": []
}
```
---
### 11  获取推荐数据：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.160:9000/ReCommence/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - gender  int  类别  1 男 2 女 0不限 （选填,如果不传就是获得不分类别的书籍列表）
        - page    int  第几页,默认为1
        - size    int   每页显示，默认为6

 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        {
            "id": "4",
            "title": "213",
            "cover": "http://172.16.2.161:9000/Uploads/xiaoshuo/c0/0d/3829e36c7146.png",
            "author": "温泉1",
            "longIntro": "温泉2",
            "wordCount": "123",
            "gender": "2",
            "over": "1",
            "score": "2.1",
            "serializeWordCount": "123321",
            "latelyFollower": "123",
            "retentionRatio": "22.23",
            "tags": "123,312",
            "isfree": "1",
            "majorCate": "9",
            "lastChapter": "1000",
            "updated": "0"
        },
        {
            "id": "3",
            "title": "温泉",
            "cover": "http://172.16.2.161:9000/Uploads/xiaoshuo/ff/26/0e01e56386f3.png",
            "author": "温泉1",
            "longIntro": "温泉2",
            "wordCount": "112",
            "gender": "2",
            "over": "1",
            "score": "3.2",
            "serializeWordCount": "123321",
            "latelyFollower": "123",
            "retentionRatio": "11.22",
            "tags": "123,312",
            "isfree": "1",
            "majorCate": "10",
            "lastChapter": "1231",
            "updated": "1551171508"
        }
    ]
}
``` 
> id:id
> titile:名称  
> author:作者
> cover :封面
> cates  分类
> longIntro 描述
> latelyFollower 追书人数
> retentionRatio 留存率
> serializeWordCount 日更新字数
> label 标签
> wordCount 本书字数
> score 评分
> isfree:是否免费 1,是 0 不是
> over  是否完结 1完结 0 没有完结
> lastChapter  最后一章节
> updated  最后书籍时间
> 

---
### 12、任务列表：（第二版任务列表有改动）
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.161:9000/Ta/1
 - 请求参数： sign=密文参数
 - 业务请求参数
     
 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        {
            "id": "2",
            "name": "每日分享",
            "describe": "每日分享"
        }
    ]
}
```
```
> id: 任务ID
> neme:任务名称  
> describe:任务描述    
```
---
### 13 任务上报接口：(第二版已经弃用,但是兼容第一版)
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.161:9000/TastL/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - token      token （不是必传,如果不传默认为UUID登陆）
        - id      任务id


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
    ]
}
```
---
---
### 14 搜索列表：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.161:9000/Search/1
 - 请求参数： sign=密文参数
 - 业务请求参数
        - key     string 搜索关键字
        - page    int  第几页,默认为1
        - size    int   每页显示，默认为6


 - 响应数据格式： json
 - 明文返回值如下：
``` json
{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        {
            "id": "11",
            "title": "试婚老公，要给力",
            "cover": "xiaoshuo/29/7a/d5ca89c2e543.jpg",
            "author": "佚名",
            "longIntro": "九点，夜色撩人。 　　 　　唐宁在单身派对上喝得有点多，所以被未婚夫带回了公寓，只是当她头疼欲裂的睁开眼时，……",
            "wordCount": "200000",
            "gender": "2",
            "over": "1",
            "score": "8.0",
            "serializeWordCount": "115",
            "latelyFollower": "115",
            "retentionRatio": "31.00",
            "tags": "现代言情,爽文",
            "isfree": "1",
            "majorCate": "9",
            "lastChapter": "115",
            "updated": "0"
        }
    ]
}
```
``` 
> id:id
> titile:名称  
> author:作者
> cover :封面
> cates  分类
> longIntro 描述
> latelyFollower 追书人数
> retentionRatio 留存率
> serializeWordCount 日更新字数
> label 标签
> wordCount 本书字数
> score 评分
> isfree:是否免费 1,是 0 不是
> over  是否完结 1完结 0 没有完结
> lastChapter  最后一章节
> updated  最后书籍时间
> 
```
---

### 15 搜索关键字：
      
 - 请求方式： POST
 - 请求地址：http://172.16.2.161:9000/Key/1
 - 请求参数： sign=密文参数
 - 业务请求参数


 - 响应数据格式： json
 - 明文返回值如下：
```

{
    "errorno": 200,
    "msg": "操作成功",
    "data": [
        "试"
    ]
}
```

### 16、升级检测接口：

~~~
* 根据客户端上报的渠道、版本号判断是否需要更新apk
- 请求方式： POST
- 请求地址： http://172.16.2.161:9000/Upgrad/1
- 请求参数： sign=密文参数
- 响应数据格式： json
- 明文返回值如下：

~~~

~~~
#需要更新时返回
{
      "errno": 0,
      "data": {
            "update": true, # 需要更新返回 true
            "version":"xxxxx",
            "apk_url":"http://cdn.the.url.of.apk/or/reader.apk", // CDN链接下载地址
            "update_log":"xxxx",  // 更新日志，用于在界面上显示",
            "forced_updating" : "0" // 0 不强制 1 强制
            "md5":"xxxxxxxxxxxxxx", // full-apk的md5
            "target_size":"601132", // full-apk的size
          }
}

~~~
~~~
#不需要更新时返回
{
      "errno": 0,
      "data": {
            "update": false, # 不需要更新返回 false
          }
}

~~~


### 17、 用户信息接口：

~~~
* 根据客户端上报的渠道、版本号判断是否需要更新apk
- 请求方式： POST
- 请求地址：http://172.16.2.161:9000/UserIn/1
- 请求参数： sign=密文参数
- 业务请求参数
        - token     token登录必传,否则会默认为UUID登录
 
 - 响应数据格式： json
 - 明文返回值如下：
{
    "errorno": 200,
    "msg": "操作成功",
    "data": {
        "expire": "1555489795",
        "invitation_code": "WYPSHX",
        "id": "16",
        "gold": "1542",
        "u_type": "游客",
        "uni_id": "f4ac2697e26a1252a9481d4e2e2da7f1aof",
        "mobile": "",
        "username": "",
        "nickname": "金1金1金1金1",
        "sex": "2",
        "cover": "http://172.16.2.160:9000/Uploads/head_portrait/5f/09/f439b87e1a52.jpg",
        "utid": "1",
        "devid": "eed98548-5d0c-4e92-beb2-71c47cc1640a"
       "invitation" : "1" 
    }
}

~~~
``` 
> expire:  过期时间 如果没有过期就会返回到期 的时间戳, 否则 返回0
> gold:名称    剩余金币数量
> u_type:  用户类型
> mobile :用户手机号
> uni_id  :用户独一无二的ID
> sex 性别 1:男 2 女 -1 保密
> cover : 头像
> invitation_code 邀请码
> nickname：昵称
> invitation : 该用户是否填写过邀请码 1 填写过 0 没有
>reader_time: 阅读时长 时间为秒
```

### 18、策略接口：

~~~
* 根据客户端上报的渠道、版本号判断是否需要更新apk
- 请求方式： POST
- 请求地址：172.16.2.161:9000/Strate/1
- 请求参数： sign=密文参数
- 业务请求参数
  
 
 - 响应数据格式： json
 - 明文返回值如下：
{
    "errorno": 200,
    "msg": "操作成功",
    "data": {
        "SHARE_TIMES_LIMIT": "3",
        "STRATEGY_FREE_AD_OPEN": "1",
        "STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY": "10",
        "STRATEGY_FREE_AD_SHOW_INTV": "15",
        "STRATEGY_AD_OPEN": "1",
        "STRATEGY_AD_CHAPTER_END_INTV": "15",
        "AD_BROWSE_LIMIT": "5",
        "EXCHANGE_GOLD_NUM": "100",
        "STRATEGY_START_RATIO": "30,70",
        "STRATEGY_CHAPTER_END_RATIO": "30,70",
        "STRATEGY_VIDEO_RATIO": "30,70",
        "STRATEGY_RED_PACKET": "1",
        "BANNER_AD_SWITCH": "0",
        "BANNER_AD_RATIO": "10,20,70",
        "BANNER_AD_LIMIT": "6",
        "CONTACT_US": "666666"
    }
}
~~~
``` 
> STRATEGY_FREE_AD_OPEN:  自由广告展示开关
> STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY":自由广告每天展示次数
> STRATEGY_FREE_AD_SHOW_INTV:  自由广告展示间隔(单位:分钟)
> STRATEGY_AD_OPEN :广告SDK展示开关
> STRATEGY_AD_CHAPTER_END_INTV ：章节末广告展示间隔
> AD_BROWSE_LIMIT : 每日浏览量总数限制
> EXCHANGE_GOLD_NUM: 缓存一本书所需的金币
> SHARE_TIMES_LIMIT ： 每日分享总数限制
> STRATEGY_START_RATIO ：开屏广告SDK展示配置
> STRATEGY_CHAPTER_END_RATIO 章节末尾广告SDK展示配置
> STRATEGY_VIDEO_RATIO 视频任务广告SDK展示配置
> STRATEGY_RED_PACKET 红包开关 1为开 0为关
> BANNER_AD_SWITCH  Banner广告开关
> BANNER_AD_RATIO   Banner广告比例（广、穿、百）
> BANNER_AD_LIMIT Banner 广告间隔
> CONTACT_US 联系客服
```














