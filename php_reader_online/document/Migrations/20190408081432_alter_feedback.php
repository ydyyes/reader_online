<?php


use Phinx\Migration\AbstractMigration;

class AlterFeedback extends AbstractMigration
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
    ALTER TABLE `xs_feedback` 
ADD COLUMN `model` varchar(100) NOT NULL DEFAULT '' AFTER `content`,
ADD COLUMN `vcode` varchar(20) NOT NULL DEFAULT 0 AFTER `model`;
INSERT INTO `sys_config`(`name`, `type`, `option`, `value`, `comment`, `tpl`, `validate_type`, `delfault`, `create_at`, `update_at`, `status`) VALUES ('STRATEGY_RED_PACKET', 'input', '', '1', '红包开关{1:开，0:关}', '', 'string', '', 1554712928, 1554712966, 1);
EOL;
    $this->execute($sql);

    }
}
