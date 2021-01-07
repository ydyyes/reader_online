<?php


use Phinx\Migration\AbstractMigration;

class AddTableValConfig extends AbstractMigration
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
        $sql = <<<EEE
INSERT INTO `sys_config`( `name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ( 'STRATEGY_FREE_AD_OPEN', 'radio', '{\"1\":\"开\",\"0\":\"关\"}', '1', '自由广告展示开关(0关 1开)', '', 'string', '', 1551929581, 0, 1);
INSERT INTO `sys_config`( `name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ( 'STRATEGY_FREE_AD_SHOW_TIMES_EVERYDAY', 'input', '', '10', '自由广告每天展示次数 默认10', '', 'digits', '', 1551929604, 0, 1);
INSERT INTO `sys_config`( `name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ( 'STRATEGY_FREE_AD_SHOW_INTV', 'input', '', '15', '自由广告展示间隔(单位:分钟)', '', 'string', '', 1551929632, 0, 1);
INSERT INTO `sys_config`( `name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ( 'STRATEGY_AD_OPEN', 'radio', '', '1', '广告SDK展示开关(0关,1开)', '', 'digits', '', 1551929655, 0, 1);
INSERT INTO `sys_config`( `name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ( 'STRATEGY_AD_CHAPTER_END_INTV', 'input', '', '15', '章节末广告展示间隔(单位:分钟)默认为10', '', 'digits', '', 1551929675, 0, 1);
INSERT INTO `sys_config`( `name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ( 'USER_NO_ADS', 'input', '', '7', '新用户无广告天数(单位:天)', '', 'digits', '', 1551929699, 0, 1);
EEE;
        $this->execute($sql);


    }
}
