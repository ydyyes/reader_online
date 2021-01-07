<?php
/**
 * User:Xxx
 */

namespace Admin\Controller;


class YouMiLogController extends  SystemController
{
    public $model = "YouMi";

    public function _filter(&$map)
    {
        $_search = search_map();

        if (isset($_search['uni_id']))
        {
            $map['uni_id'] = $_search['uni_id'];
        }

    }

}