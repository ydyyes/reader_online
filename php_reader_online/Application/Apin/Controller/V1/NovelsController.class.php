<?php
/**
 * author:liu.
 */

namespace Apin\Controller\V1;


class NovelsController extends  BaseController
{
    public function read(){


         $novels_model = D('Admin/Novels');
        $page =(int)$this->parm['page']?:1;
        $size =(int)$this->parm['size']?:6;
        if(!empty($this->parm['m_id'])){
           $data =  $novels_model->getDataByCates($this->parm['m_id'],$page,$size);

        }elseif(!empty($this->parm['type'])){
            $data =  $novels_model->getDataByNid($this->parm['type'],$page,$size);
        }else {
            $data = $novels_model->getDataByCates('', $page, $size);
        }

        $data = $data?:[];

       $this->returnResult(200,'',$data);
    }
    protected function _check_para($data){
        if(!empty($data['m_id'])){
           self::isPositiveInteger($this->parm['m_id']);
        }



    }






}