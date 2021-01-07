<?php
/**
 * author:liu.
 */

namespace Common\Validate;


class IdMustValidate extends BaseValidate
{
    protected $rule = [
        'id' => 'isPositiveInteger',
    ];

}