# --- !Ups
CREATE TABLE `user_account` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(64) NOT NULL,
  `password_salt` varchar(64) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  `failure_count` int(11) NOT NULL DEFAULT '0',
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `is_password_change` tinyint(1) NOT NULL DEFAULT '0',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_account_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;


insert into user_account(
  email,
  password,
  password_salt,
  first_name,
  last_name,
  role_id,
  failure_count
) values (
  'hoge.fuga@foo.bar',
  '83627ffa5ab48ecae9d0aafe55940d3d19040319e4b26a94f92d56b6734962e1', --password
  'f911422a271cf8a986b8a19d1e948c4d8ac4050bf090dd00d0d3e982c57647b8',
  'hoge',
  'fuga',
  1,
  0
);

# --- !Downs
DROP TABLE user_account;
