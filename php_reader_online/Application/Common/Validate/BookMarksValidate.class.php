<?php
/**
 * User:Xxx
 */

namespace Common\Validate;


class BookMarksValidate extends BaseValidate
{
    protected $rule = [
        'label'     => 'isNumber',
        'percentage'=> 'isNumber',
    ];

}