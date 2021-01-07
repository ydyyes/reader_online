<?php


use Phinx\Migration\AbstractMigration;

class AlterBannerChnid extends AbstractMigration
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
ALTER TABLE `xs_carousel_map` 
ADD COLUMN `chn_id` varchar(255) NULL COMMENT '渠道号' AFTER `img`;

ALTER TABLE `xs_carousel_map` 
ADD COLUMN `local_inner` smallint(6) NOT NULL DEFAULT 0 COMMENT '1 福利中心 2兑换金币 3邀请好友 ' AFTER `fid`;
EOL;
       $this->execute($sql);

    }
}
