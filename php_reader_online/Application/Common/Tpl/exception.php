<?php
/**
 * author:liu.
 */
\Think\Log::write(json_encode($e),'User-defined Exceptions');
echo json_encode(['code' => '50999','message' => '错误信息' ],JSON_UNESCAPED_UNICODE);
