<?php
/**
 * author:liu.
 */

namespace Admin\Controller\Xs;


use Admin\Controller\SystemController;

class XsFeedbackController extends SystemController
{
    public $model = "feedback";


    public function _filter(&$map)
    {
        $_search = search_map();
        if (isset($_search['uid']))
        {
            $map['uid'] =$_search['uid'];
        }

    }
}