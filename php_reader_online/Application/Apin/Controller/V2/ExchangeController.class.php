<?php
/**
 * User:Xxx
 */

namespace Apin\Controller\V2;


use Apin\Controller\V1\BaseController;

class ExchangeController extends BaseController
{
        public function read(){

            $exchange_model = D('Admin/ExchangeGold');
            $res = $exchange_model->getData();

            return $this->returnResult(200,'',$res);

        }

}