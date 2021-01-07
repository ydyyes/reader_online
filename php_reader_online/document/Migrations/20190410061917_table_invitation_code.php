<?php


use Phinx\Migration\AbstractMigration;

class TableInvitationCode extends AbstractMigration
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
ALTER TABLE `xs_users` 
ADD COLUMN `cover` varchar(100) NULL DEFAULT '' COMMENT '头像图片' AFTER `nickname`,
ADD COLUMN `sex` tinyint(2) NULL DEFAULT -1 COMMENT '1:男2:女0:保密' AFTER `cover`,
ADD COLUMN `invitation_code` varchar(20) NULL DEFAULT '' COMMENT '邀请码' AFTER `sex`,
ADD INDEX `invitation_code`(`invitation_code`) USING HASH;

CREATE TABLE `xs_invitation_code_log`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `uid` int(10) NOT NULL,
  `pa_uid` int(10) NOT NULL,
  `pa_mobile` varchar(20) NULL DEFAULT '',
  `create_time` int(10) NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `uid`(`uid`) USING HASH,
  INDEX `pa_uid`(`pa_uid`) USING HASH
);
EOL;

        $this->execute($sql);

    }
}
