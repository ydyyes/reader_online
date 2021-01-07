<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Apin\Controller\V1\BaseController;

class HRankingListController  extends  BaseController
{
    public function read(){
       $data = [];
       if($this->parm['type']) {
           $novels_model = D('Admin/Novels');
           $page =(int)$this->parm['page']?:1;
           $size =(int)$this->parm['size']?:6;
           $data = $novels_model->getHDataByNid($this->parm['type'], $page, $size);
       }

       $this->returnResult(200,'',$data);
    }

}