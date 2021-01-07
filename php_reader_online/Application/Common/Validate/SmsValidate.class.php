<?php
/**
 * author:liu.
 */

namespace Common\Validate;


class SmsValidate extends BaseValidate
{
    protected $rule = [
        'mobile'    => 'isNotEmpty|isMobile',
        'areacode'  => 'isNotEmpty'
    ];

}