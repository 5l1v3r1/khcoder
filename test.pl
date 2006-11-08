#! /usr/bin/perl

#---------------------------------------------#
#   GUI��Ȥ鷺�˥ƥ��Ƚ�����Ԥ�������ץ�   #
#---------------------------------------------#

#----------------#
#   ��ޤ�ʸ��   # 

use strict;
use vars qw($config_obj $project_obj $kh_version);
BEGIN{
	use Cwd qw(cwd);
	use lib cwd.'/kh_lib';
	use kh_sysconfig;
	$config_obj = kh_sysconfig->readin('./config/coder.ini',&cwd);
}

$config_obj->sqllog(1);       # �ǥХå���

use kh_project;
use kh_projects;

#------------------------#
#   �ץ������Ȥ򳫤�   #

# ʬ���оݥե�����Υѥ���DB̾��ľ�ܻ���
kh_project->temp(
	target  => 'f:/home/Koichi/Study/perl/test_data/STATS_law/data/p1676.txt',
	dbname  => 'khc3',
)->open;

# �ƥ��ȥץ���
use mysql_words;
print "project opened:\n";
print "\tkinds_all: ".mysql_words->num_kinds_all."\n";
print "\tkinds: ".mysql_words->num_kinds."\n";
print "\tall: ".mysql_words->num_all."\n\n";

#----------------#
#   �ƥ��Ƚ���   #
#----------------#

# ���ַ�¬(1)
use Benchmark;
my $t0 = new Benchmark;


# �����ǥƥ��Ƚ����¹�
use mysql_ready::fc;
&mysql_ready::fc::calc_by_db;

# ���ַ�¬(2)
my $t1 = new Benchmark;
print timestr(timediff($t1,$t0)),"\n";


__END__
