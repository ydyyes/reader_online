<?php


use Phinx\Migration\AbstractMigration;

class InsertTableTask extends AbstractMigration
{
    /**
     * Change Method.
     *
     * Write your reversible migrations using this method.
     *
     * More information on writing migrations is available here:
     * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
     *
     * The following commands can be used in this method and Phinx will
     * automatically reverse them when rolling back:
     *
     *    createTable
     *    renameTable
     *    addColumn
     *    renameColumn
     *    addIndex
     *    addForeignKey
     *
     * Remember to call "create()" or "update()" and NOT "save()" when working
     * with the Table class.
     */
    public function change()
    {
        $sql =<<<EOL
INSERT INTO `xs_task`(`name`, `describe`, `type`, `task_type`, `way`, `num`, `status`, `create_time`, `update_time`) VALUES ('每日签到', '每日签到', 2, 1, 1, 20, 1, 1552531667, 1552531667);
INSERT INTO `xs_task`(`name`, `describe`, `type`, `task_type`, `way`, `num`, `status`, `create_time`, `update_time`) VALUES ('分享奖励', '分享奖励', 2, 2, 1, 20, 1, 1552531886, 1552531886);
INSERT INTO `xs_task`(`name`, `describe`, `type`, `task_type`, `way`, `num`, `status`, `create_time`, `update_time`) VALUES ('阅读奖励', '阅读奖励', 2, 3, 1, 20, 1, 1552531932, 1552531932);
INSERT INTO `xs_task`(`name`, `describe`, `type`, `task_type`, `way`, `num`, `status`, `create_time`, `update_time`) VALUES ('绑定手机号', '绑定手机号', 1, 4, 1, 24, 1, 1552535308, 1552535308);
INSERT INTO `xs_task`(`name`, `describe`, `type`, `task_type`, `way`, `num`, `status`, `create_time`, `update_time`) VALUES ('观看视频广告', '观看视频广告', 2, 5, 1, 100, 1, 1552535338, 1552535338);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_1', 'input', '', '20', '签到1天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_2', 'input', '', '20', '签到2天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_3', 'input', '', '20', '签到3天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_4', 'input', '', '20', '签到4天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_5', 'input', '', '20', '签到5天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_6', 'input', '', '20', '签到6天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('SIGN_7', 'input', '', '20', '签到7天', '', 'string', '', 1552532495, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('AD_BROWSE_LIMIT', 'input', '', '5', '观看视频奖励限制', '', 'string', '', 1552563950, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('EXCHANGE_GOLD_NUM', 'input', '', '100', '兑换书籍需要的金币', '', 'string', '', 1552640707, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('STRATEGY_START_RATIO', 'input', '', '30,70', '开屏广告SDK展示配置', '', 'string', '', 1553053624, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('STRATEGY_CHAPTER_END_RATIO', 'input', '', '30,70', '章节末尾广告SDK展示配置', '', 'string', '', 1553053681, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('STRATEGY_VIDEO_RATIO', 'input', '', '30,70', '视频任务广告SDK展示配置', '', 'string', '', 1553053719, 1553053814, 1);
EOL;
        $this->execute($sql);


    }
}
