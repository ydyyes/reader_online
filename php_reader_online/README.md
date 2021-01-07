
## 生产环境部署

####安装PHP
1. mac:http://www.gimoo.net/t/1409/540524a33e2e0.html
2. Centos:https://webtatic.com/packages/php55/
3. php -r "readfile('https://getcomposer.org/installer');" | php
4. composer mirror:http://pkg.phpcomposer.com/

####安装composer并更新所有代码
1. cd /wwwroot/kspocket/
2. composer update
3. 生产环境中需要运行 `composer dump-autoload --optimize` 进行自动加载的效率优化

####建立相关临时文件，复制配置文件并配置Data/Config文件中的相关参数
1. mkdir -p Data/Config  Data/Runtime Data/Session Data/Uploads
2. cp -r document/Config Data/
3. chmod -R 777 Data
4. ln -s ../Data/Uploads Public/Uploads
5.修改Data/Config/database.php内的db配置等，替换url内 ATTACH下 DEFAULT、STATIC地址为正式cdn地址；

####建立项目数据库
1. mysqladmin create pocket

####数据库迁移
6. 查看状态 `php vendor/bin/phinx status -c Data/Config/migrate.php`
7. 执行迁移 `php vendor/bin/phinx migrate -c Data/Config/migrate.php`
8. 新建迁移 `php vendor/bin/phinx create TableModify -c Data/Config/migrate.php`

####生成后台菜单
1. php cli.php menu/make

#### 设置crontab 任务
php cli.php Log all  记录各种日志，每隔1或2分钟即可。
php cli.php ResetCache all   充值各种缓存，每隔10/15分钟即可。
php cli.php  Day all  关键字 每天执行一次      
检查是否安装unzip、unrar工具。放到$PATH可调取的bin／sbin目录下  

php cli.php ClearDetail clear 用命令插入书籍时,有更改 重建缓存 用这个  
php cli.php CreateChapterList start 执行更改后的chapterlist重建  
php cli.php EditOrderStatus start   自动取消订单  
 

###php cli.php TaskLog/start     定时任务 执行任务写入





####建立nginx配置文件，修改nginx配置文件
1. cp document/nginx.server.conf /usr/local/etc/nginx/servers
2. nginx -t
3. nginx -s reload

##其它常用操作

####生成接口文档
1. php vendor/bin/sami.php update sami.php

####进行单元测试
1. php test.php all 自动测试所有测试用例
2. php test.php TestEnv test_extension_loaded 测试指定方法

####命令行版本
1. php cli.php
2. php repl.php

## 项目信息
```
├── Application    代码目录，只读，禁止Web访问
│   ├── Admin
│   ├── Cli
│   ├── Common
│   ├── Gold
│   ├── Helper
│   └── Test
├── CHANGELOG.md
├── Data           数据目录，读写，禁止Web访问
│   ├── Config
│   ├── Runtime
│   ├── Session
│   └── Uploads
├── Public
│   ├── Uploads     建议绑定单独域名访问
│   ├── api
│   ├── index.php   项目入口，只读
│   ├── robots.txt  
│   ├── static      建议绑定单独域名访问
│   └── v2.php      接口入口，只读
├── README.md
├── cli.php
├── composer.json
├── composer.lock
├── document
│   ├── Config
│   ├── Migrations
│   ├── composer.json
│   ├── nginx.server.conf
│   └── php-fpm.conf
├── repl.php       REPL入口，只读，禁止Web访问
├── sami.php       项目文档生成入口文件
├── test.php       单元测试入口文件
└── vendor         composer目录，只读，禁止Web访问
```

## 相关文档

```
编码规范
    PSR-0 自动加载
    PSR-1 基本代码规范
    PSR-2 代码样式
    PSR-3 日志接口
    PSR-4 自动加载（优先）

    英文版：https://github.com/php-fig/fig-standards/tree/master/accepted
    中文版：https://github.com/PizzaLiu/PHP-FIG

开发环境
    Linux、Mac
    PHP5.5      :http://itopic.org/php5-upgrading.html
    Mysql5.5    :http://www.oschina.net/p/percona+server
    MongoDB3.0  :http://www.oschina.net/news/60169/mongodb-3-0-final
    Redis       :http://www.oschina.net/p/redis
    Memcached   :http://www.oschina.net/p/memcached
    Sphinx

    Composer        :http://www.phpcomposer.com/
    ThinkPHP 3.2.3  :http://document.thinkphp.cn/

    phinx           :http://phinx.readthedocs.org/en/latest/index.html
	sami            :https://github.com/FriendsOfPHP/Sami

    Scala           :http://www.scala-lang.org/
    Spark
    Hadoop
    Cloudera CDH5   :http://www.cloudera.com/content/cloudera/en/documentation

开发工具
    ZendStudio:http://www.zend.com/products/studio/downloads
    git:http://git-scm.com/book/zh/v1
        http://git.oschina.net
        https://github.com/
        https://coding.net/

    vagrant:http://segmentfault.net/blog/fenbox/1190000000264347
    navicat:http://www.navicat.com.cn

    genymotion:https://www.genymotion.com/
    charles:http://www.charlesproxy.com/

    aapt:https://code.google.com/p/android-apktool/

    DWZ:http://j-ui.com/
```

## 常见问题

####PDOException thrown with message &quot;SQLSTATE[HY000]: General error: 1364 Field 'name' doesn't have a default value
解决办法:http://blog.rekfan.com/articles/366.html
临时解决办法为使用root登陆mysql，执行 SET @@GLOBAL.sql_mode="NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION";
