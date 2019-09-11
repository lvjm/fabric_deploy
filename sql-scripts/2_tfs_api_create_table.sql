CREATE DATABASE IF NOT EXISTS db_place_holder default charset utf8mb4 COLLATE utf8mb4_general_ci;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON db_place_holder.* TO user_place_holder@"%" IDENTIFIED BY 'password_place_holder';
flush privileges;
use db_place_holder;

CREATE TABLE `merchant_api_info` (
  `id`             int(11)      NOT NULL AUTO_INCREMENT
  COMMENT 'id',
  `app_name`       varchar(20)  NOT NULL
  COMMENT '应用名',
  `app_key`        varchar(128) NOT NULL
  COMMENT '应用key',
  `contact_person` varchar(20)  NOT NULL
  COMMENT '应用联系人',
  `contact_phone`  varchar(11)  NOT NULL
  COMMENT '应用联系电话',
  `org`            varchar(11)  NOT NULL
  COMMENT '所属组织',
  `secret`         varchar(128)  NOT NULL
  COMMENT 'msp注册使用的密码',
  `app_user_obj`   text COMMENT 'appUser对象序列化',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_app_name` (`app_name`) USING BTREE
)
  ENGINE = InnoDB
  COMMENT ='商户应用授权表';

CREATE TABLE `retry_spot` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(20) NOT NULL COMMENT '名称',
  `description` varchar(1024) DEFAULT NULL COMMENT '描述',
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `class_name` varchar(256) NOT NULL COMMENT '调用类全名',
  `invoked_method_name` varchar(256) NOT NULL COMMENT '调用类方法名',
  `invoked_method_parameters` text NOT NULL COMMENT '调用类方法参数',
  `recover_method_name` varchar(256) NOT NULL COMMENT '恢复调用方法',
  `recover_parameters` mediumblob NOT NULL COMMENT '恢复调用参数',
  `exception` text NOT NULL COMMENT '异常',
  `status` int(1) NOT NULL DEFAULT '0' COMMENT '0-创建,1-再次执行成功',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=gbk COMMENT='retry spot 现场记录表';

CREATE TABLE `file_record` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `biz_id` varchar(256) NOT NULL COMMENT 'biz id',
  `owner` varchar(256) DEFAULT NULL COMMENT 'owner',
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `file_name` varchar(1024) NOT NULL COMMENT '文件名',
  `file_type` varchar(256) NOT NULL COMMENT '文件类型',
  `status` int(1) NOT NULL DEFAULT '0' COMMENT '0-创建,1-归档',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=gbk COMMENT='file 记录表';

INSERT INTO `merchant_api_info` (`id`, `app_name`, `app_key`, `contact_person`, `contact_phone`, `org`, `secret`, `app_user_obj`) VALUES (1, 'test_app_oneKey', 'VfZ0ff8x+621NhpaFCn3e83Jqoqofjk/i79DTw37K9P9JSvxy+OjnXqAb8FG3+p6h63W+SfVw5TfWWKAyuacxlrkGFyeXacv6Bmke1chEWYhrAdm2mdIX4Fk2tXjWVg7', 'foy', '13333333333', 'org1', '', NULL);
INSERT INTO `merchant_api_info` (`id`, `app_name`, `app_key`, `contact_person`, `contact_phone`, `org`, `secret`, `app_user_obj`) VALUES (2, 'acunetix_scanner', 'OjnXqAb8FG3wdttdd', 'acunetix_scanner', '13333333333', 'org1', '', NULL);




