<?php
/**
 * author:liu.
 */

namespace Common\Validate;


class ChapterInfoValidate extends BaseValidate
{
    protected $rule = [
        'id' => 'isNotEmpty|isPositiveInteger',
        'label' => 'isNumber'
    ];




}