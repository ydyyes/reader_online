<?php
/**
 * User:Xxx
 */

namespace Admin\Model;


class InvitationModel extends SystemModel
{
    protected $trueTableName = 'xs_invitation_code_log';

    public function checkInviationT($uid){

        $res = self::where(['uid' => $uid])->count();

        return $res;
    }
    public function checkPaInviation($pa_uid){

        $res = self::where(['pa_uid' => $pa_uid])->find();

        return $res;
    }

}