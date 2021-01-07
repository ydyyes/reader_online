<?php
/**
 * User:Xxx
 */

return array(
    'URL_ROUTE_RULES' => array( //定义路由规则
        'ApinRegist/:id'    => 'Apin/V1/Regist/create',
        'Cate/:id'          => 'Apin/V1/Cates/read',
        'Banners/:id'       => 'Apin/V1/Banner/read',
        'ChapterIn/:id'     => 'Apin/V1/ChapterInfo/read',
        'GetTime/:id'       => 'Apin/V1/Time/index',
        'Novel/:id'         => 'Apin/V1/Novels/read',
        'Detail/:id'        => 'Apin/V1/NovelDetail/read',
        'ChapterLt/:id'     => 'Apin/V1/ChapterList/read',
        'Recommence/:id'    => 'Apin/V1/Recommend/read',
        'Feecba/:id'        => 'Apin/V1/Feecback/create',
        'Sms/:id'           => 'Apin/V1/Message/create',
        'Bindph/:id'        => 'Apin/V1/BindPhone/create',
        'Ta/:id'            => 'Apin/V1/Task/read',
        'TastL/:id'         => 'Apin/V1/TaskLog/create',
        'Search/:id'        => 'Apin/V1/SearchList/read',
        'Key/:id'           => 'Apin/V1/KeyList/read',
        'Upgrad/:id'        => 'Apin/V1/Upgrade/read',
        'UserIn/:id'        => 'Apin/V1/UserInfo/read',
        'Strate/:id'        => 'Apin/V1/Strategy/read',
        'VtwTest'           => 'Apin/V2/Index/index',
        'VtwSign/:id'       => 'Apin/V2/Sign/read',
        'VtwTaskPro/:id'    => 'Apin/V2/TaskProcessing/create',
        'VtwGold/:id'       => 'Apin/V2/GoldProcessing/save',
        'VtwExchange/:id'   => 'Apin/V2/Exchange/read',
        'VtwGoldLog/:id'    => 'Apin/V2/GoldLog/read',
        'VtwTaskStatus/:id' => 'Apin/V2/GetTaskStatus/read',
        'VtwSetH/:id'       => 'Apin/V2/SetHSign/read',
        'VtwInviationLog/:id'  => 'Apin/V2/InviationLog/read',
        'VtwSetUserInfo/:id'   => 'Apin/V2/SetUserInfo/save',
        'VtwHRank/:id'         => 'Apin/V2/HRankingList/read',


        'VthChapterLt/:id'     => 'Apin/V3/ChapterList/read',
        'VthChapterIn/:id'     => 'Apin/V3/ChapterInfo/read',
        'VthMarkRe/:id'        => 'Apin/V3/ChapterInfo/read',
        'VthMarkSave/:id'      => 'Apin/V3/ChapterInfo/save',
        'VthProduct/:id'       => 'Apin/V3/ProductList/read',
        'VthOrder/:id'         => 'Apin/V3/Order/create',
        'VthOrRes/:id'         => 'Apin/V3/Order/find',
        'VthOrderRed/:id'      => 'Apin/V3/Order/read',




    ),

    'URL_MAP_RULES' => array(
        'youMiCallback'    => 'Vend/YouMiCallback/add',
        'payCallback'       => 'Vend/PayCallback/save',
    )


);
