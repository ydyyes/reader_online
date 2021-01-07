<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


class RecommendController extends BaseController
{
    protected  $no_uuid = 1;
    public function  read(){
        $where = [];
        $page =(int)$this->parm['page']?:1;
        $size =(int)$this->parm['size']?:6;
        if(!empty($this->parm['gender'])){
            $where['gender'] =  $this->parm['gender'];
        }
        $channel_id = D('Admin/SysChannel')
            ->where(['name' => $this->header['channel']])
            ->getField('id');
        if($channel_id){
            $data =  D('Admin/Novels')->RecommedList($where,$page,$size,$channel_id);
        }
        $data = $data?:[];
        $this->returnResult(200,'',$data);

    }
    protected function _check_para($data)
    {
      if(!empty($this->parm['gender'])){
          self::isPositiveInteger($this->parm['gender']);
      }
    }



}