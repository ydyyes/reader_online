<?php
/**
 * author:liu.
 */

namespace Common\Validate;


class MobileValidate extends BaseValidate
{

    protected $rule = [
        'mobile' => 'isNotEmpty|isMobile',
        'code'   => 'isPositiveInteger',
        'areacode' => 'isNotEmpty'
    ];

}