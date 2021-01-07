<?php


use Phinx\Migration\AbstractMigration;

class AlterSqlConfig extends AbstractMigration
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
        $sql = <<<EOL
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('BANNER_AD_SWITCH', 'input', '', '0', 'banner广告开关(1:开,0:关)', '', 'digits', '', 1557384261, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('BANNER_AD_RATIO', 'input', '', '10,20,70', 'banner广告展示配置（广、穿、百）', '', 'string', '', 1557384352, 0, 1);
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('BANNER_AD_LIMIT', 'input', '', '5', 'banner广告展示间隔（单位：秒）', '', 'string', '', 1557384379, 0, 1);
EOL;

        $this->execute($sql);


    }
}
