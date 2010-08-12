/*
Navicat MySQL Data Transfer

Source Server         : connection
Source Server Version : 50022
Source Host           : localhost:3306
Source Database       : gemjade

Target Server Type    : MYSQL
Target Server Version : 50022
File Encoding         : 65001

Date: 2010-08-12 12:26:14
*/

SET FOREIGN_KEY_CHECKS=0;
-- ----------------------------
-- Table structure for `point`
-- ----------------------------
DROP TABLE IF EXISTS `point`;
CREATE TABLE `point` (
  `id` char(50) NOT NULL,
  `longitude` double NOT NULL,
  `latitude` double NOT NULL,
  `longZone` char(10) NOT NULL,
  `latZone` char(10) NOT NULL,
  `utmLoc` point NOT NULL,
  `type` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of point
-- ----------------------------
INSERT INTO `point` VALUES ('123', '121.443297', '31.221891', '51', 'R', '\0\0\0\0\0\0\0\0\0\0\0°wA\0\0\0€‚\\JA', 'user');
