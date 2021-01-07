<?php
/**
 * User:Xxx
 */

namespace Admin\Model;


class BookMarksModel
{

    const COUNT_NUM =100;
    public function bookMarkCacheKey($uni_id, $book_id){
        return  C('REDIS_PREFIX').'marks_list_'.$uni_id.'_'.$book_id;
    }

}