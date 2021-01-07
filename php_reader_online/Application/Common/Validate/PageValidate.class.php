<?php
/**
 * User:Xxx
 */

namespace Common\Validate;


class PageValidate extends BaseValidate
{
    protected $rule = [
        'page' => 'isPositiveInteger',
        'size' => 'isPositiveInteger'
    ];
}